# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /api/v1/news/batch_process' do
  include_context 'api_authenticated'

  let(:valid_params) do
    {
      urls: ['https://example.com/news-1'],
      topics: ['Transport'],
      mentions: ['Mention1']
    }
  end

  let(:service_result) { ServiceResult.new(success: true, payload: { received: 1, processed: 1 }) }

  before do
    create(:topic, name: 'Transport')
    create(:mention, name: 'Mention1')
    allow(NewsProcessingService).to receive(:call).and_return(service_result)
  end

  describe 'POST /api/v1/news/batch_process' do
    context 'when authenticated' do
      it 'processes news successfully' do
        post '/api/v1/news/batch_process', params: valid_params

        expect(response).to have_http_status(:ok)
        expect(NewsProcessingService).to have_received(:call).with(
          hash_including('urls' => ['https://example.com/news-1'])
        )
      end

      it 'returns service payload' do
        post '/api/v1/news/batch_process', params: valid_params

        json_response = JSON.parse(response.body)
        expect(json_response['received']).to eq(1)
        expect(json_response['processed']).to eq(1)
      end
    end

    context 'when service fails' do
      let(:service_result) { ServiceResult.new(success: false, error: 'Service error') }

      it 'returns error response' do
        post '/api/v1/news/batch_process', params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Service error')
      end
    end

    context 'when not authenticated' do
      include_context 'api_authenticated', false

      it 'returns unauthorized' do
        post '/api/v1/news/batch_process', params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
