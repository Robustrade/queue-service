require_relative '../../app/validators/params_validator'

RSpec.describe ParamsValidator do
  describe '.validate_structure' do
    it 'validates matching structures' do
      expected = { 'key1' => 'value1', 'key2' => 'value2' }
      actual = { 'key1' => 'value1', 'key2' => 'value2' }
      expect(ParamsValidator.validate_structure(expected, actual)).to be_empty
    end

    it 'returns error for mismatched structures' do
      expected = { 'key1' => 'value1', 'key2' => 'value2' }
      actual = { 'key1' => 'value1' }
      expect(ParamsValidator.validate_structure(expected,
                                                actual)).to include('Hash size mismatch at root. Expected: 2, Actual: 1.')
    end
  end

  describe '.validate_data' do
    it 'validates correct payload' do
      payload = [
        { 'name' => 'param1', 'value' => 'string', 'regex_validation' => '.*' },
        { 'name' => 'param2', 'value' => '123', 'regex_validation' => '\d+' }
      ]
      expect(ParamsValidator.validate_data(payload)).to be_empty
    end

    it 'returns error for missing keys in payload' do
      payload = [
        { 'name' => 'param1', 'value' => 'string' }
      ]
      expect(ParamsValidator.validate_data(payload)).to include('Missing required key(s) / Value(s) at index 0.')
    end

    it 'returns error for invalid regex validation' do
      payload = [
        { 'name' => 'param1', 'value' => 'string', 'regex_validation' => '[' }
      ]
      expect { ParamsValidator.validate_data(payload) }.to raise_error(RuntimeError, /Invalid regex/)
    end
  end

  describe '.compare_structure' do
    it 'compares matching structures' do
      expected = { 'key1' => 'value1', 'key2' => 'value2' }
      actual = { 'key1' => 'value1', 'key2' => 'value2' }
      expect(ParamsValidator.compare_structure(expected, actual)).to be_empty
    end

    it 'returns error for mismatched structures' do
      expected = { 'key1' => 'value1', 'key2' => 'value2' }
      actual = { 'key1' => 'value1' }
      expect(ParamsValidator.compare_structure(expected,
                                               actual)).to include('Hash size mismatch at root. Expected: 2, Actual: 1.')
    end
  end

  describe '.regex_valid?' do
    it 'validates correct regex' do
      expect(ParamsValidator.regex_valid?('123', '\d+')).to be true
    end

    it 'returns false for incorrect regex' do
      expect(ParamsValidator.regex_valid?('abc', '\d+')).to be false
    end

    it 'raises error for invalid regex pattern' do
      expect { ParamsValidator.regex_valid?('abc', '[') }.to raise_error(RuntimeError, /Invalid regex/)
    end
  end

  describe '.path_description' do
    it 'returns root for empty path' do
      expect(ParamsValidator.path_description('')).to eq('root')
    end

    it 'returns formatted path for non-empty path' do
      expect(ParamsValidator.path_description('key1/key2')).to eq("'key1/key2'")
    end
  end
end
