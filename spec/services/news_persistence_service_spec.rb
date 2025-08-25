# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsPersistenceService, type: :service do
  subject(:service) { described_class.new(news_items) }

  let(:topic) { create(:topic, name: 'Transport') }
  let(:mention) { create(:mention, name: 'Mention1') }

  let(:news_items) do
    [
      {
        'titulo' => 'Valid News',
        'tipo_publicacion' => 'nota',
        'fecha' => '2025-01-09',
        'soporte' => 'web',
        'medio' => 'Test Media',
        'tema' => 'Transport',
        'menciones' => ['Mention1']
      },
      {
        'titulo' => '', # Invalid - empty title
        'tipo_publicacion' => 'nota',
        'fecha' => '2025-01-09',
        'soporte' => 'web',
        'medio' => 'Test Media'
      }
    ]
  end

  before do
    topic
    mention
  end

  describe '#call' do
    it 'persists valid news and reports errors for invalid ones' do
      expect { service.call }.to change(News, :count).by(1)

      result = service.call

      expect(result[:success_count]).to eq(1)
      expect(result[:persisted_news]).to have(1).item
      expect(result[:errors]).to have(1).item
      expect(result[:errors].first).to include('Failed to save news')
    end

    it 'associates mentions correctly' do
      service.call

      news = News.last
      expect(news.mentions.pluck(:name)).to include('Mention1')
    end

    it 'handles persistence errors gracefully' do
      allow(NewsRecordBuilder).to receive(:new).and_raise(StandardError.new('DB Error'))

      result = service.call

      expect(result[:success_count]).to eq(0)
      expect(result[:errors]).to all(include('Persistence error'))
    end
  end
end
