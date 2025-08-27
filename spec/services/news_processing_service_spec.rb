# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsProcessingService, type: :service do
  subject(:service) { described_class.new(params) }

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

  before do
    # Clean up all news to ensure test idempotency
    News.destroy_all
  end

  before do
    create(:topic, name: 'Transport')
    create(:mention, name: 'Mention1')
  end

  describe '.call' do
    context 'with valid parameters' do
      it 'returns success result and persists news' do
        # Mock AI service response
        ai_response = {
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
              'ALCANCE' => 10_000,
              'COTIZACION' => 0.0,
              'VALORACION' => 'neutral',
              'FACTOR POLITICO' => 'medio',
              'MENCIONES' => ['Mention1']
            }
          ],
          errors: []
        }

        allow_any_instance_of(described_class).to receive(:call_external_service).and_return(ai_response)

        result = nil
        expect { result = described_class.call(params) }.to change(News, :count).by(1)
        expect(result).to be_success
        expect(result.payload[:received]).to eq(2)
        expect(result.payload[:processed_by_ai]).to eq(2)
        expect(result.payload[:news]).to be_present
      end

      it 'persists news with correct attributes and associations' do
        ai_response = {
          received: 1,
          processed: 1,
          news: [
            {
              'TITULO' => 'Persisted News',
              'TIPO PUBLICACION' => 'nota',
              'FECHA' => '2025-01-09',
              'SOPORTE' => 'web',
              'MEDIO' => 'Test Media',
              'SECCION' => 'Politics',
              'AUTOR' => 'Test Author',
              'ENTREVISTADO' => nil,
              'TEMA' => 'Transport',
              'LINK' => 'https://example.com/news-1',
              'ALCANCE' => 50_000,
              'COTIZACION' => 100.50,
              'VALORACION' => 'positivo',
              'FACTOR POLITICO' => 'alto',
              'MENCIONES' => ['Mention1']
            }
          ],
          errors: []
        }

        allow_any_instance_of(described_class).to receive(:call_external_service).and_return(ai_response)

        result = described_class.call(params)

        news = News.last
        expect(news.title).to eq('Persisted News')
        expect(news.topic.name).to eq('Transport')
        expect(news.mentions.pluck(:name)).to include('Mention1')
        expect(news.valuation).to eq('positive')
        expect(news.audience_size).to eq(50_000)
        expect(news.quotation).to eq(100.50)
      end
    end

    context 'with invalid URLs' do
      let(:params) { { urls: ['invalid-url'], topics: [], mentions: [] } }

      it 'returns failure result' do
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.error).to include(a_string_including('Invalid URL format'))
      end
    end

    context 'with invalid topics' do
      let(:params) { { urls: valid_urls, topics: ['NonexistentTopic'], mentions: [] } }

      it 'returns failure result' do
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.error).to include(a_string_including('Invalid topics'))
      end
    end

    context 'with invalid mentions' do
      let(:params) { { urls: valid_urls, topics: [], mentions: ['NonexistentMention'] } }

      it 'returns failure result' do
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.error).to include(a_string_including('Invalid mentions'))
      end
    end
  end

  describe '#call' do
    context 'when AI service fails' do
      before do
        allow(service).to receive(:call_external_service).and_raise(StandardError.new('AI service error'))
      end

      it 'handles errors gracefully' do
        result = service.call

        expect(result).to be_failure
        expect(result.error).to include('Processing failed')
      end
    end
  end

  describe 'constants' do
    it 'has correct ministries' do
      expect(described_class::MINISTRIES).to include(
        'Ministerio de Cultura',
        'Ministerio de Cultura de Buenos Aires'
      )
    end

    it 'has correct ministers' do
      expect(described_class::MINISTERS).to include(
        'Ricardes',
        'Gabriela Ricardes',
        'Ministro',
        'Ministra'
      )
    end
  end
end
