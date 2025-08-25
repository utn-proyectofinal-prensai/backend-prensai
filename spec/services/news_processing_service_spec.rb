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
              'titulo' => 'Test News 1',
              'tipo_publicacion' => 'nota',
              'fecha' => '2025-01-09',
              'soporte' => 'web',
              'medio' => 'Test Media',
              'seccion' => 'Politics',
              'autor' => 'Test Author',
              'entrevistado' => nil,
              'tema' => 'Transport',
              'link' => 'https://example.com/news-1',
              'alcance' => 10_000,
              'cotizacion' => 0.0,
              'valoracion' => 'neutral',
              'factor_politico' => 'medio',
              'gestion' => 'GCBA',
              'texto_plano' => 'Test content',
              'crisis' => 'no',
              'menciones' => ['Mention1']
            }
          ],
          errors: []
        }

        allow_any_instance_of(described_class).to receive(:call_external_service).and_return(ai_response)

        expect { described_class.call(params) }.to change(News, :count).by(1)

        result = described_class.call(params)
        expect(result).to be_success
        expect(result.payload[:received]).to eq(2)
        expect(result.payload[:processed]).to eq(1)
        expect(result.payload[:news]).to be_present
      end

      it 'persists news with correct attributes and associations' do
        ai_response = {
          received: 1,
          processed: 1,
          news: [
            {
              'titulo' => 'Persisted News',
              'tipo_publicacion' => 'nota',
              'fecha' => '2025-01-09',
              'soporte' => 'web',
              'medio' => 'Test Media',
              'seccion' => 'Politics',
              'autor' => 'Test Author',
              'entrevistado' => nil,
              'tema' => 'Transport',
              'link' => 'https://example.com/news-1',
              'alcance' => 50_000,
              'cotizacion' => 100.50,
              'valoracion' => 'positivo',
              'factor_politico' => 'alto',
              'gestion' => 'GCBA',
              'texto_plano' => 'Full news content',
              'crisis' => 'no',
              'menciones' => ['Mention1']
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
      let(:params) { { urls: ['invalid-url'] } }

      it 'returns failure result' do
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.error).to include('Invalid URL format')
      end
    end

    context 'with invalid topics' do
      let(:params) { { urls: valid_urls, topics: ['NonexistentTopic'] } }

      it 'returns failure result' do
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.error).to include('Invalid topics')
      end
    end

    context 'with invalid mentions' do
      let(:params) { { urls: valid_urls, mentions: ['NonexistentMention'] } }

      it 'returns failure result' do
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.error).to include('Invalid mentions')
      end
    end
  end

  describe '#call' do
    context 'when AI service fails' do
      before do
        allow(service).to receive(:call_ai_service).and_raise(StandardError.new('AI service error'))
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
        'Pepe Pompin',
        'Ministro',
        'Ministro de cultura'
      )
    end
  end
end
