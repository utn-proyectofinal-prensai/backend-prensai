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

  describe 'associations' do
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to belong_to(:topic) }
    it { is_expected.to have_many(:clipping_news).dependent(:destroy) }
    it { is_expected.to have_many(:news).through(:clipping_news) }
  end

  describe 'validations' do
    context 'with valid news ids' do
      it 'is valid and normalizes string ids to integers' do
        news.update!(topic: topic, date: Date.current)
        clipping = described_class.new(base_attributes.merge(news_ids: [news.id.to_s], topic_id: topic.id))

        expect(clipping).to be_valid
        expect(clipping.news_ids).to eq([news.id])
        expect(clipping.topic_id).to eq(topic.id)
      end
    end

    context 'with an empty news list' do
      it 'adds a validation error' do
        clipping = described_class.new(base_attributes.merge(news_ids: [], topic_id: topic.id))

        expect(clipping).not_to be_valid
        expect(clipping.errors[:news_ids]).to include(
          I18n.t('activerecord.errors.models.clipping.attributes.news_ids.blank')
        )
      end
    end
  end

  describe 'callbacks' do
    it 'builds and refreshes metrics when news ids change' do
      test_date = Date.new(2025, 1, 1)
      positive_news = create(:news, valuation: 'positive', topic: topic, date: test_date)
      negative_news = create(:news, valuation: 'negative', topic: topic, date: test_date)

      clipping = nil

      travel_to Time.zone.local(2025, 1, 1, 10, 0) do
        clipping = described_class.create!(
          name: 'Weekly Summary',
          start_date: test_date,
          end_date: test_date + 1.day,
          creator: creator,
          news_ids: [positive_news.id, negative_news.id],
          topic_id: topic.id
        )

        metrics = clipping.metrics.deep_symbolize_keys
        expect(metrics[:news_count]).to eq(2)
        expect(metrics[:generated_at]).to eq(Time.current.iso8601)
        expect(metrics[:valuation][:positive][:count]).to eq(1)
        expect(metrics[:valuation][:negative][:count]).to eq(1)
        expect(clipping.reload.news.pluck(:id)).to contain_exactly(positive_news.id, negative_news.id)
      end

      neutral_news = create(:news, valuation: 'neutral', topic: topic, date: test_date)

      travel_to Time.zone.local(2025, 1, 2, 12, 0) do
        clipping.update!(news_ids: [positive_news.id, neutral_news.id])
        refreshed_metrics = clipping.reload.metrics.deep_symbolize_keys

        expect(refreshed_metrics[:news_count]).to eq(2)
        expect(refreshed_metrics[:generated_at]).to eq(Time.current.iso8601)
        expect(refreshed_metrics[:valuation][:negative][:count]).to eq(0)
        expect(refreshed_metrics[:valuation][:neutral][:count]).to eq(1)
        expect(clipping.reload.news.pluck(:id)).to contain_exactly(positive_news.id, neutral_news.id)
      end
    end
  end
end
