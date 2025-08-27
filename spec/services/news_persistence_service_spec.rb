# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsPersistenceService, type: :service do
  subject(:service) { described_class.new(news_items) }

  let(:topic) { create(:topic, name: 'Transport') }
  let(:mention) { create(:mention, name: 'Mention1') }

  let(:valid_news_item) do
    {
      'TITULO' => 'Valid News',
      'TIPO PUBLICACION' => 'nota',
      'FECHA' => '2025-01-09',
      'SOPORTE' => 'web',
      'MEDIO' => 'Test Media',
      'SECCION' => 'Politics',
      'AUTOR' => 'Test Author',
      'ENTREVISTADO' => 'Test Interviewee',
      'LINK' => 'https://example.com/valid-news',
      'ALCANCE' => 50_000,
      'COTIZACION' => 100.50,
      'VALORACION' => 'positivo',
      'FACTOR POLITICO' => 'alto',
      'TEMA' => 'Transport',
      'MENCIONES' => ['Mention1']
    }
  end

  let(:invalid_news_item) do
    {
      'TITULO' => '', # Invalid - empty title
      'TIPO PUBLICACION' => 'nota',
      'FECHA' => '2025-01-09',
      'SOPORTE' => 'web',
      'MEDIO' => 'Test Media',
      'LINK' => 'https://example.com/invalid-news'
    }
  end

  before do
    # Clean up all news to ensure test idempotency
    News.destroy_all
    topic
    mention
  end

  describe '#call' do
    context 'with valid news items' do
      let(:news_items) { [valid_news_item] }

      it 'successfully persists news' do
        result = nil
        expect { result = service.call }.to change(News, :count).by(1)

        expect(result[:success_count]).to eq(1)
        expect(result[:persisted_news].size).to eq(1)
        expect(result[:errors]).to be_empty
      end

      it 'associates mentions correctly' do
        service.call
        news = News.last
        expect(news.mentions.pluck(:name)).to include('Mention1')
      end

      it 'returns correct result structure' do
        result = service.call

        expect(result).to have_key(:success_count)
        expect(result).to have_key(:persisted_news)
        expect(result).to have_key(:errors)
        expect(result[:success_count]).to be_an(Integer)
        expect(result[:persisted_news]).to be_an(Array)
        expect(result[:errors]).to be_an(Array)
      end
    end

    context 'with invalid news items' do
      let(:news_items) { [invalid_news_item] }

      it 'reports errors for invalid news' do
        expect { service.call }.not_to change(News, :count)

        result = service.call
        expect(result[:success_count]).to eq(0)
        expect(result[:persisted_news]).to be_empty
        expect(result[:errors].size).to eq(1)
        expect(result[:errors].first[:reason]).to include('Failed to save news')
      end

      it 'builds error messages with correct structure' do
        result = service.call
        error = result[:errors].first

        expect(error).to have_key(:url)
        expect(error).to have_key(:reason)
        expect(error[:reason]).to include('Failed to save news')
      end
    end

    context 'with mixed valid and invalid news items' do
      let(:news_items) { [valid_news_item, invalid_news_item] }

      it 'persists valid news and reports errors for invalid ones' do
        result = nil
        expect { result = service.call }.to change(News, :count).by(1)

        expect(result[:success_count]).to eq(1)
        expect(result[:persisted_news].size).to eq(1)
        expect(result[:errors].size).to eq(1)
      end
    end

    context 'with empty news items array' do
      let(:news_items) { [] }

      it 'handles empty arrays gracefully' do
        result = service.call

        expect(result[:success_count]).to eq(0)
        expect(result[:persisted_news]).to be_empty
        expect(result[:errors]).to be_empty
      end
    end
  end

  describe 'error handling' do
    context 'when NewsRecordBuilder raises an error' do
      let(:news_items) { [valid_news_item] }

      before do
        allow(NewsRecordBuilder).to receive(:call).and_raise(StandardError.new('Unexpected error'))
      end

      it 'catches the error and returns error result' do
        result = service.call

        expect(result[:success_count]).to eq(0)
        expect(result[:errors]).to all(include(reason: /Persistence error/))
        expect(result[:errors].first[:reason]).to include('Unexpected error')
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(/Error persisting news/)
        service.call
      end
    end
  end
end
