class MessageProcessorWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['MESSAGE_PROCESSOR_SQS_QUEUE'], auto_delete: true

  def perform(sys_msg, body)
    message = JSON.parse(body)
    process_message(message)
  rescue StandardError => e
    Rails.logger.error { "Error processing message: #{e.message}" }
  end

  private

  def process_message(message)
    event_name = message['event_name']
    event = Event.find_by(name: event_name)
    return unless event

    received_message = event.message_receiveds.create(
      req_payload: message['payload'],
      received_at: Time.current.utc
    )

    metadata = event.message_metadata
    return unless valid_message?(message['payload'], metadata)

    received_message.update(
      enqueued_at: Time.current.utc
    )

    response = call_callback_url(event.callback_url, message['payload'], event.service_owner.secret_token)

    received_message.update(
      worked_processed_at: Time.current.utc,
      status_code: response.code,
      response_payload: response.parsed_response,
      total_retries: received_message.total_retries + 1
    )
  end

  def valid_message?(payload, metadata)
    metadata.all? do |meta|
      value = payload[meta['key']]
      if meta.required && value.nil?
        Rails.logger.error { "Required key not found: #{meta['key']}" }
        return false
      elsif meta.regex_validation && !value.match?(meta.regex_validation)
        Rails.logger.error { "Regex validation failed for key: #{meta['key']}" }
        return false
      else
        true
      end
    end
  end

  def call_callback_url(callback_url, payload, secret_token)
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{secret_token}"
    }

    HTTParty.post(callback_url,
                  body: payload.to_json,
                  headers: headers,
                  debug_output: $stdout)
  end
end
