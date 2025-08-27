# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /api/v1/news/batch_process' do
  subject { post '/api/v1/news/batch_process', params:, headers: auth_headers, as: :json }

  let(:service_result) do
    ServiceResult.new(success: true, payload: { received: 1, processed_by_ai: 1, persisted: 0, news: [], errors: [] })
  end

  let(:params) do
    {
      urls: ['https://example.com/news-1'],
      topics: ['Transport'],
      mentions: ['Mention1']
    }
  end

  before do
    create(:topic, name: 'Transport')
    create(:mention, name: 'Mention1')
    allow(NewsProcessingService).to receive(:call).and_return(service_result)
  end

  context 'when authenticated' do
    include_context 'with authenticated regular user via JWT'

    context 'with valid params' do
      it 'processes news successfully' do
        subject
        expect(response).to have_http_status(:ok)
        expect(NewsProcessingService).to have_received(:call).with(params)
      end

      it 'returns service payload' do
        subject
        expect(response.parsed_body['received']).to eq(1)
        expect(response.parsed_body['processed_by_ai']).to eq(1)
      end
    end

    context 'with invalid params' do
      let(:params) { { links: ['https://example.com/news-1'] } }

      it 'returns bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when service fails' do
      let(:service_result) { ServiceResult.new(success: false, error: 'Service error') }

      it 'returns error response' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq('Service error')
      end
    end
  end

  context 'when not authenticated' do
    let(:auth_headers) { { 'Content-Type' => 'application/json' } }

    it 'returns unauthorized' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
