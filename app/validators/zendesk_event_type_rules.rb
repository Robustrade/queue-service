# frozen_string_literal: true

# ZendeskEventTypeRules defines the rules for different event types and provides methods to validate and fetch required keys.
class ZendeskEventTypeRules
  EVENT_RULES = {
    'kyc_check' => {
      required_body_keys: %i[subject description]
    },
    'pin_change' => {
      required_body_keys: %i[subject description updated_at]
    }
  }.freeze

  # Fetch the rule for the given event type
  def self.rule_for(event_type)
    EVENT_RULES[event_type] || {}
  end

  # Check if the given event type is supported
  def self.supported?(event_type)
    EVENT_RULES.key?(event_type)
  end

  # Fetch the required body keys for the given event type
  def self.required_keys_for(event_type)
    rule_for(event_type)[:required_body_keys] || []
  end

  # Generate the dynamic permit str for the given event type
  def self.permit_str_for(event_type)
    [:type, { body: required_keys_for(event_type) }]
  end
end
