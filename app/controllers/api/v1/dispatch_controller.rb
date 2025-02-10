# frozen_string_literal: true

module Api
  module V1
    class DispatchController < ApplicationController
      before_action :get_json_file!, only: [:create]
      before_action :validate_params_structure, only: [:create]
      before_action :validate_params_data, only: [:create]

      def create
        required_params = params.to_unsafe_h['dispatch']
        MessagePublisher.publish(params[:queue_name], required_params)

        if defined?(SMS_PROVIDER_REQ_COUNTER)
          SMS_PROVIDER_REQ_COUNTER.observe(1, queue_name: params[:queue_name].to_s,
                                              is_outgoing: true)
        end

        render json: { message: 'Message sent to the queue' }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def get_json_file!
        file_name = params[:queue_name]
        return render json: { error: 'Queue name is required' }, status: :bad_request unless file_name.present?

        file_path = Rails.root.join('lib', 'json_definitions', "#{file_name}.json")

        @file = JSON.parse(File.read(file_path))
      rescue Errno::ENOENT
        render json: {
                 error: "File not found for queue: #{file_name}. File should be present in lib/json_definitions as #{file_name}.json"
               },
               status: :not_found
      end

      def validate_params_structure
        errors = ParamsValidator.validate_structure(@file, params.to_unsafe_h['dispatch'])

        return unless errors.any?

        render json: {
          error: 'Parameter structure validation failed',
          details: errors
        }, status: :bad_request
      rescue StandardError => e
        render json: { error: e.message }, status: :bad_request
      end

      def validate_params_data
        payload = params.to_unsafe_h['dispatch']['payload']

        errors = ParamsValidator.validate_data(payload)

        return unless errors.any?

        render json: {
          error: 'Parameter data validation failed',
          details: errors
        }, status: :bad_request
      rescue StandardError => e
        render json: { error: e.message }, status: :bad_request
      end
    end
  end
end
