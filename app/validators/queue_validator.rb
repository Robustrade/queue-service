# frozen_string_literal: true

# QueueValidator is responsible for validating and resolving queue names from the environment variables.
class QueueValidator
  # Load all valid queues from the ENV
  VALID_QUEUES = ENV.select { |k, _| k.start_with?('AMAZON_SQS_') }.transform_values(&:to_s).freeze

  def self.valid?(queue_name)
    VALID_QUEUES.value?(queue_name)
  end

  def self.resolve(queue_name_key)
    VALID_QUEUES[queue_name_key] || raise("Invalid or unrsource queue name: #{queue_name_key}")
  end
end
