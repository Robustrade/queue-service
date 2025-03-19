# frozen_string_literal: true

module Api
  module V1
    class EventsController < ApplicationController
      def create
        ActiveRecord::Base.transaction do
          service_owner = create_service_owner
          event = create_event(service_owner)
          create_message_metadata(event)

          render json: {
            message: 'Event setup successfully',
            service_owner: service_owner,
            event: event,
            metadata: event.message_metadata
          }, status: :created
        end
      rescue StandardError => e
        Rails.logger.error(e.message)
        render json: { message: e.message }, status: :unprocessable_entity
        ActiveRecord::Rollback
      end

      private

      def create_service_owner
        ServiceOwner.create!(service_owner_params)
      end

      def create_event(service_owner)
        service_owner.events.create!(event_params)
      end

      def create_message_metadata(event)
        metadata_params[:metadata].each do |meta|
          event.message_metadata.create!(meta)
        end
      end

      def service_owner_params
        params.require(:service_owner).permit(:name, :email, :api_key, :secret_token)
      end

      def event_params
        params.require(:event).permit(:name, :callback_url)
      end

      def metadata_params
        params.require(:message_metadata).permit(metadata: %i[key data_type required regex_validation])
      end
    end
  end
end
