# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsPersistenceService, type: :service do
  subject(:service) { described_class.new(news_items, creator_id) }

  let(:topic) { create(:topic, name: 'Transport') }
  let(:mention) { create(:mention, name: 'Mention1') }
  let(:creator_id) { create(:user).id }

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

      it 'sets creator_id correctly' do
        service.call
        news = News.last
        expect(news.creator_id).to eq(creator_id)
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
        expect(result[:errors].first[:reason]).to include(I18n.t('errors.messages.blank'))
      end

      it 'builds error messages with correct structure' do
        result = service.call
        error = result[:errors].first

        expect(error).to have_key(:url)
        expect(error).to have_key(:reason)
        expect(error[:reason]).to include(I18n.t('errors.messages.blank'))
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
    context 'when a news item has a duplicate link' do
      before { create(:news, link: valid_news_item['LINK']) }

      let(:news_items) { [valid_news_item] }

      it 'returns a duplicate link error' do
        result = service.call

        expect(result[:success_count]).to eq(0)
        expect(result[:errors]).to contain_exactly(
          include(
            url: valid_news_item['LINK'],
            reason: I18n.t('api.errors.news.duplicate_link')
          )
        )
      end
    end

    context 'when the persistence layer raises a validation error' do
      let(:news_items) { [valid_news_item] }

      before do
        invalid_record = News.new
        invalid_record.errors.add(:base, :invalid)
        allow(NewsRecordBuilder).to receive(:call)
          .and_raise(ActiveRecord::RecordInvalid.new(invalid_record))
      end

      it 'returns a validation failed error' do
        result = service.call

        expect(result[:success_count]).to eq(0)
        expect(result[:errors]).to contain_exactly(
          include(
            url: valid_news_item['LINK'],
            reason: I18n.t('api.errors.news.validation_failed')
          )
        )
      end
    end

    context 'when NewsRecordBuilder raises an error' do
      let(:news_items) { [valid_news_item] }

      before do
        allow(NewsRecordBuilder).to receive(:call).and_raise(StandardError.new('Unexpected error'))
      end

      it 'catches the error and returns error result' do
        result = service.call

        expect(result[:success_count]).to eq(0)
        expect(result[:errors]).to all(include(reason: I18n.t('api.errors.news.internal_error')))
      end
    end
  end
end
