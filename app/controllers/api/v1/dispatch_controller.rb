# frozen_string_literal: true

module Api
  module V1
    class DispatchController < ApplicationController
      before_action :get_json_file!, only: [:create]
      before_action :validate_params_structure, only: [:create]
      before_action :validate_params_data, only: [:create]
      before_action :create_requested_str, only: [:create]

      def create
        MessagePublisher.publish(params[:queue_name], @requested_str)

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

      def create_requested_str # for zendesk integration
        unless params[:event_name].present? && params[:payload].present?
          return render json: { error: 'Event name and payload are required' }, status: :bad_request
        end

        @requested_str = {
          event_name: params[:event_name],
          body: {}
        }

        params[:payload].each do |item|
          @requested_str[:body][item[:name]] = item[:datatype]
        end

        @requested_str
      rescue StandardError => e
        render json: { error: e.message }, status: :bad_request
      end
    end
  end
end
