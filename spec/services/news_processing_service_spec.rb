# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsProcessingService, type: :service do
  subject(:result) { service.call }

  let(:service) { described_class.new(params) }

  let(:valid_urls) { ['https://example.com/news-1', 'https://example.com/news-2'] }
  let(:valid_topics) { ['Transport'] }
  let(:valid_mentions) { ['Mention1'] }
  let(:creator) { create(:user) }
  let(:params) do
    {
      urls: valid_urls,
      topics: valid_topics,
      mentions: valid_mentions,
      creator_id: creator.id
    }
  end

  let(:external_ai_service_response) do
    {
      ok: true,
      received: 2,
      processed: 2,
      news: [
        {
          'TITULO' => 'Test News 1',
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
    # Clean up all news to ensure test idempotency
    News.destroy_all
    create(:topic, name: 'Transport')
    create(:mention, name: 'Mention1')
  end

  describe '.call' do
    context 'with valid parameters' do
      before do
        allow(service).to receive(:call_external_service).and_return(external_ai_service_response)
      end

      it 'returns success result' do
        expect(result).to be_success
      end

      it 'persists news with correct attributes and associations' do
        expect { result }.to change(News, :count).by(1)
      end

      it 'persists news with correct creator_id' do
        result
        created_news = News.last
        expect(created_news.creator_id).to eq(creator.id)
      end
    end

    context 'with invalid URLs' do
      let(:params) { { urls: ['invalid-url'], topics: [], mentions: [], creator_id: creator.id } }

      it 'returns failure result' do
        expect(result).to be_failure
        expect(result.errors).to include(a_string_including('Invalid URL format'))
      end
    end

    context 'with invalid topics' do
      let(:params) { { urls: valid_urls, topics: ['NonexistentTopic'], mentions: [], creator_id: creator.id } }

      it 'returns failure result' do
        expect(result).to be_failure
        expect(result.errors).to include(a_string_including('Invalid topics'))
      end
    end

    context 'with invalid mentions' do
      let(:params) { { urls: valid_urls, topics: [], mentions: ['NonexistentMention'], creator_id: creator.id } }

      it 'returns failure result' do
        expect(result).to be_failure
        expect(result.errors).to include(a_string_including('Invalid mentions'))
      end
    end

    context 'when AI service fails' do
      before do
        allow(service).to receive(:call_external_service).and_raise(StandardError, 'AI service error')
      end

      it 'handles errors gracefully' do
        expect(result).to be_failure
        expect(result.errors).to include('Processing failed')
      end
    end

    context 'when all urls were already processed' do
      let(:valid_urls) { ['https://example.com/news-1'] }

      before do
        create(:news, link: valid_urls.first)
        allow(ExternalAiService).to receive(:process_news)
      end

      it 'skips the external AI service' do
        result
        expect(ExternalAiService).not_to have_received(:process_news)
      end

      it 'returns a successful result with duplicate error information' do
        payload = result.payload

        expect(result).to be_success
        expect(payload[:received]).to eq(0)
        expect(payload[:processed_by_ai]).to eq(0)
        expect(payload[:persisted]).to eq(0)
        expect(payload[:errors]).to eq([
                                         {
                                           url: 'https://example.com/news-1',
                                           reason: I18n.t('api.errors.news.duplicate_link')
                                         }
                                       ])
      end
    end

    context 'when some urls were already processed' do
      let(:valid_urls) { ['https://example.com/news-1', 'https://example.com/news-3'] }
      let(:external_ai_service_response) do
        {
          ok: true,
          received: 1,
          processed: 1,
          news: [
            {
              'TITULO' => 'Test News 3',
              'TIPO PUBLICACION' => 'nota',
              'FECHA' => '2025-01-10',
              'SOPORTE' => 'web',
              'MEDIO' => 'Test Media 3',
              'SECCION' => 'Politics',
              'AUTOR' => 'Test Author 3',
              'ENTREVISTADO' => nil,
              'TEMA' => 'Transport',
              'LINK' => 'https://example.com/news-3',
              'ALCANCE' => '12.000',
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
        create(:news, link: 'https://example.com/news-1')
        allow(ExternalAiService).to receive(:process_news).and_return(external_ai_service_response)
      end

      it 'calls the external AI service only with fresh urls' do
        result
        expect(ExternalAiService).to have_received(:process_news).with(hash_including(urls: ['https://example.com/news-3']))
      end

      it 'returns duplicate errors alongside processed results' do
        payload = result.payload

        expect(result).to be_success
        expect(payload[:received]).to eq(1)
        expect(payload[:processed_by_ai]).to eq(1)
        expect(payload[:persisted]).to eq(1)
        expect(payload[:errors]).to include(
          url: 'https://example.com/news-1',
          reason: I18n.t('api.errors.news.duplicate_link')
        )
      end
    end
  end
end
