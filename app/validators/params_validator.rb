# frozen_string_literal: true

# ParamsValidator
# This class provides validation methods for parameter structure and data.
# It is designed to ensure that input parameters match the expected structure
# and that values conform to specific constraints like regex validation.
#
# Methods:
# - validate_structure(expected, actual): Validates that the structure of the `actual` params matches the `expected` structure.
# - validate_data(payload): Validates that the `payload` array contains the required keys and values conform to regex rules.
# - compare_structure(expected, actual, path): Compares the structure of nested objects and arrays for consistency.
# - regex_valid?(value, regex): Validates a value against a regex pattern, raising an error for invalid regex.
# - path_description(path): Helper method for generating descriptive error paths.
class ParamsValidator
  def self.validate_structure(expected, actual)
    compare_structure(expected, actual)
  rescue StandardError => e
    ["Error during structure validation: #{e.message}"]
  end

  def self.validate_data(payload)
    errors = []

    return ['Payload should be an array of objects.'] unless payload.is_a?(Array)

    payload.each_with_index do |item, index|
      name = item['name']
      value = item['value']
      regex_validation = item['regex_validation']

      unless name && value && regex_validation
        errors << "Missing required key(s) / Value(s) at index #{index}."
        next
      end

      errors << "Invalid value for 'value' at index #{index}." unless regex_valid?(value, regex_validation)
    end

    errors
  end

  def self.compare_structure(expected, actual, path = '')
    errors = []

    unless (expected.is_a?(Hash) && actual.is_a?(Hash)) || (expected.is_a?(Array) && actual.is_a?(Array)) ||
           (expected.is_a?(String) && actual.is_a?(String))
      errors << "Type mismatch at #{path_description(path)}. Expected: #{expected.class}, Actual: #{actual.class}."
      return errors
    end

    if expected.is_a?(Hash)
      if actual.size != expected.size
        errors << "Hash size mismatch at #{path_description(path)}. Expected: #{expected.size}, Actual: #{actual.size}."
      end

      expected.each do |key, value|
        if actual.key?(key)
          errors.concat(compare_structure(value, actual[key], "#{path}/#{key}"))
        else
          errors << "Missing key: '#{key}' at #{path_description(path)}."
        end
      end
    elsif expected.is_a?(Array)
      if actual.size != expected.size
        errors << "Array size mismatch at #{path_description(path)}. Expected: #{expected.size}, Actual: #{actual.size}."
      end

      expected.each_with_index do |value, index|
        if actual[index]
          errors.concat(compare_structure(value, actual[index], "#{path}[#{index}]"))
        else
          errors << "Missing value at index #{index} in array at #{path_description(path)}."
        end
      end
    else
      unless expected.instance_of?(actual.class)
        errors << "Type mismatch at #{path_description(path)}. Expected: #{expected.class}, Actual: #{actual.class}."
      end
    end

    errors
  end

  def self.regex_valid?(value, regex)
    return true if regex.nil? || regex.empty?

    !!(value.to_s =~ Regexp.new(regex))
  rescue RegexpError => e
    raise "Invalid regex: #{regex}. Error: #{e.message}"
  end

  def self.path_description(path)
    path.empty? ? 'root' : "'#{path}'"
  end
end
