require 'rails_helper'

RSpec.describe Api::V1::DispatchController, type: :controller do
  describe 'POST #create' do
    let(:valid_params) do
      {
        queue_name: 'test_queue',
        event_name: 'test_event',
        dispatch: {
          payload: [
            { name: 'param1', value: 'string', regex_validation: '.*' },
            { name: 'param2', value: '123', regex_validation: '\d+' }
          ]
        }
      }
    end

    let(:invalid_params) do
      {
        queue_name: 'test_queue',
        dispatch: {
          payload: [
            { name: 'param1', value: 'string' }
          ]
        }
      }
    end

    before do
      allow(MessagePublisher).to receive(:publish)
      allow(File).to receive(:read).and_return('{"payload": [{"name": "param1", "value": "string", "regex_validation": ".*"}, {"name": "param2", "value": "integer", "regex_validation": "\\d+"}]}')
    end

    context 'with valid params' do
      it 'publishes the message and returns status ok' do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Message sent to the queue')
      end
    end

    context 'with invalid params' do
      it 'returns error for missing keys in payload' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Parameter structure validation failed')
      end
    end

    context 'when file is not found' do
      before do
        allow(File).to receive(:read).and_raise(Errno::ENOENT)
      end

      it 'returns not found error' do
        post :create, params: valid_params
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to include('File not found for queue')
      end
    end

    context 'when an exception occurs' do
      before do
        allow(MessagePublisher).to receive(:publish).and_raise(StandardError, 'Something went wrong')
      end

      it 'returns unprocessable entity status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Something went wrong')
      end
    end
  end
end
