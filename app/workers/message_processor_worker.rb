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
    if defined?(SMS_PROVIDER_REQ_COUNTER)
      SMS_PROVIDER_REQ_COUNTER.observe(1,
                                       queue_name: ENV['MESSAGE_PROCESSOR_SQS_QUEUE'],
                                       event_name: event_name,
                                       is_incoming: true)
    end
    event = Event.find_by(name: event_name)
    Rails.logger.error { "Event not found: #{event_name}" } && return unless event

    received_message = event.message_receiveds.create(
      req_payload: message['payload'],
      received_at: Time.current.utc
    )

    metadata = event.message_metadata
    return unless valid_message?(message['payload'], metadata, received_message)

    received_message.update(
      enqueued_at: Time.current.utc
    )

    response = call_callback_url(event.callback_url, message['payload'], event.service_owner.secret_token)

    if response.code == 200
      received_message.update(
        worked_processed_at: Time.current.utc,
        status_code: response.code,
        response_payload: response.parsed_response,
        total_retries: received_message.total_retries + 1
      )
    else
      received_message.update(
        error_response: response,
        total_retries: received_message.total_retries + 1
      )
    end
  end

  def valid_message?(payload, metadata, received_message)
    metadata.all? do |meta|
      value = payload[meta['key']]
      if meta.required && value.nil?
        received_message.update(error_message: "Required key not found: #{meta['key']}")
        Rails.logger.error { "Required key not found: #{meta['key']}" }
        return false
      elsif meta.regex_validation && !value.match?(meta.regex_validation)
        received_message.update(error_message: "Regex validation failed for key: #{meta['key']}")
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
