# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsProcessingService, type: :service do
  subject(:result) { service.call }

  let(:service) { described_class.new(params) }

  let(:valid_urls) { ['https://example.com/news-1', 'https://example.com/news-2'] }
  let(:valid_topics) { ['Transport'] }
  let(:valid_mentions) { ['Mention1'] }
  let(:params) do
    {
      urls: valid_urls,
      topics: valid_topics,
      mentions: valid_mentions
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
    before do
      allow(service).to receive(:call_external_service).and_return(external_ai_service_response)
    end

    context 'with valid parameters' do
      it 'returns success result' do
        expect(result).to be_success
      end

      it 'persists news with correct attributes and associations' do
        expect { result }.to change(News, :count).by(1)
      end
    end

    context 'with invalid URLs' do
      let(:params) { { urls: ['invalid-url'], topics: [], mentions: [] } }

      it 'returns failure result' do
        expect(result).to be_failure
        expect(result.errors).to include(a_string_including('Invalid URL format'))
      end
    end

    context 'with invalid topics' do
      let(:params) { { urls: valid_urls, topics: ['NonexistentTopic'], mentions: [] } }

      it 'returns failure result' do
        expect(result).to be_failure
        expect(result.errors).to include(a_string_including('Invalid topics'))
      end
    end

    context 'with invalid mentions' do
      let(:params) { { urls: valid_urls, topics: [], mentions: ['NonexistentMention'] } }

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
  end
end
