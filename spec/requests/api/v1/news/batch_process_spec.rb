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
        expect(NewsProcessingService).to have_received(:call).with(params.merge(creator_id: regular_user.id))
      end

      it 'returns service payload' do
        subject
        expect(response.parsed_body['received']).to eq(1)
        expect(response.parsed_body['processed_by_ai']).to eq(1)
      end

      it 'passes creator_id to the service' do
        subject
        expect(NewsProcessingService).to have_received(:call).with(hash_including(creator_id: regular_user.id))
      end
    end

    context 'with real service processing' do
      let(:external_ai_service_response) do
        {
          ok: true,
          received: 1,
          processed: 1,
          news: [
            {
              'TITULO' => 'Test News',
              'TIPO PUBLICACION' => 'nota',
              'FECHA' => '2025-01-09',
              'SOPORTE' => 'web',
              'MEDIO' => 'Test Media',
              'SECCION' => 'Politics',
              'AUTOR' => 'Test Author',
              'ENTREVISTADO' => nil,
              'TEMA' => 'Transport',
              'LINK' => 'https://example.com/news-1',
              'ALCANCE' => '10.000',
              'COTIZACION' => '$0.0',
              'VALORACION' => 'neutral',
              'FACTOR POLITICO' => 'medio',
              'MENCIONES' => ['Mention1']
            }
          ],
          errors: []
        }
      end

      before do
        allow(NewsProcessingService).to receive(:call).and_call_original
        allow(ExternalAiService).to receive(:process_news).and_return(external_ai_service_response)
      end

      it 'persists news with correct creator_id' do
        expect { subject }.to change(News, :count).by(1)

        created_news = News.last
        expect(created_news.creator_id).to eq(regular_user.id)
        expect(created_news.title).to eq('Test News')
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
      let(:error_object) { { message: 'Service error' } }
      let(:service_result) { ServiceResult.new(success: false, errors: [error_object]) }

      it 'returns error response' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to match([error_object.deep_stringify_keys])
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
