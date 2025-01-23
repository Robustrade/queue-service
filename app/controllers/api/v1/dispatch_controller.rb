# frozen_string_literal: true

module Api
  module V1
    # DispatchController handles the dispatching of messages to the appropriate queue.
    # It validates the queue name and sanitizes the parameters before publishing the message.
    class DispatchController < ApplicationController
      before_action :validate_queue_name, only: [:create]
      before_action :sanitize_and_validate_params, only: [:create]

      def create
        MessagePublisher.publish(params[:queue_name], @payload)

        render json: { message: 'Message sent to the queue' }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def validate_queue_name
        return if ::QueueValidator.valid?(params[:queue_name])

        render json: { error: "Invalid queue name: #{params[:queue_name]}" }, status: :bad_request
      end

      def sanitize_and_validate_params
        event_type = params.dig(:payload, :type)
        body = params.dig(:payload, :body)

        # Validate the event type
        unless validate_event_type(event_type)
          return render json: { error: "Unsupported event type: #{event_type}" }, status: :bad_request
        end

        # Dynamically permit the required keys for the event type
        permit_payload(event_type)

        # Validate that required keys are present in the body
        missing_keys = ZendeskEventTypeRules.required_keys_for(event_type) - body.keys.map(&:to_sym)
        return unless missing_keys.present?

        render json: { error: "Missing required keys: #{missing_keys.join(', ')}" }, status: :bad_request
        nil
      end

      def validate_event_type(event_type)
        ZendeskEventTypeRules.supported?(event_type)
      end

      def permit_payload(event_type)
        permitted_strcuture = ZendeskEventTypeRules.permit_str_for(event_type)
        @payload = params.require(:payload).permit(*permitted_strcuture)
      end
    end
  end
end
