# frozen_string_literal: true

# MessagePublisher is responsible for publishing messages to the specified SQS queue.
class MessagePublisher
  def self.publish(queue_name, message_body)
    queue = Shoryuken::Client.queues(queue_name)

    queue.send_message(message_body.to_json)
    Rails.logger.info("Message published to queue: #{queue_name}, body: #{message_body}")
  rescue Aws::SQS::Errors::ServiceError => e
    Rails.logger.error("Failed to publish message to queue #{queue_name}: #{e.message}")
    raise
  end
end
