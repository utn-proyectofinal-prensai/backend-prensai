# frozen_string_literal: true

require 'rails_helper'

describe Clipping do
  include ActiveSupport::Testing::TimeHelpers

  let(:creator) { create(:user) }
  let(:base_attributes) do
    {
      name: 'Weekly Summary',
      start_date: Date.current,
      end_date: Date.current + 1.day,
      creator: creator
    }
  end
  let!(:news) { create(:news) }
  let!(:topic) { create(:topic) }

  describe 'validations' do
    context 'with valid news ids' do
      it 'is valid and normalizes string ids to integers' do
        clipping = described_class.new(base_attributes.merge(news_ids: [news.id.to_s], topic_id: topic.id))

        expect(clipping).to be_valid
        expect(clipping.news_ids).to eq([news.id])
        expect(clipping.topic_id).to eq(topic.id)
      end
    end

    context 'with non positive or non numeric ids' do
      it 'adds a validation error' do
        clipping = described_class.new(base_attributes.merge(news_ids: [news.id, -1, 'foo'], topic_id: topic.id))

        expect(clipping).not_to be_valid
        expect(clipping.news_ids).to eq([news.id])
        expect(clipping.errors[:news_ids]).to include('must contain positive integer IDs')
      end
    end

    context 'with ids of news that do not exist' do
      it 'adds a validation error' do
        missing_id = News.maximum(:id).to_i + 1
        clipping = described_class.new(base_attributes.merge(news_ids: [news.id, missing_id], topic_id: topic.id))

        expect(clipping).not_to be_valid
        expect(clipping.errors[:news_ids]).to include('must reference existing news')
      end
    end
  end

  describe 'callbacks' do
    it 'builds and refreshes metrics when news ids change' do
      positive_news = create(:news, valuation: 'positive')
      negative_news = create(:news, valuation: 'negative')

      clipping = nil

      travel_to Time.zone.local(2025, 1, 1, 10, 0) do
        clipping = described_class.create!(
          base_attributes.merge(
            news_ids: [positive_news.id, negative_news.id],
            topic_id: topic.id
          )
        )

        metrics = clipping.metrics.deep_symbolize_keys
        expect(metrics[:news_count]).to eq(2)
        expect(metrics[:generated_at]).to eq(Time.current.iso8601)
        expect(metrics[:valuation][:positive][:count]).to eq(1)
        expect(metrics[:valuation][:negative][:count]).to eq(1)
      end

      neutral_news = create(:news, valuation: 'neutral')

      travel_to Time.zone.local(2025, 1, 2, 12, 0) do
        clipping.update!(news_ids: [positive_news.id, neutral_news.id])
        refreshed_metrics = clipping.reload.metrics.deep_symbolize_keys

        expect(refreshed_metrics[:news_count]).to eq(2)
        expect(refreshed_metrics[:generated_at]).to eq(Time.current.iso8601)
        expect(refreshed_metrics[:valuation][:negative][:count]).to eq(0)
        expect(refreshed_metrics[:valuation][:neutral][:count]).to eq(1)
      end
    end
  end
end
