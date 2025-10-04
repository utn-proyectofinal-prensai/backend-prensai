# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clippings::MetricsBuilder, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  describe '.call' do
    it 'aggregates metrics for the provided clipping news' do
      topic = create(:topic, crisis: true)
      positive_news = create(
        :news,
        topic: topic,
        valuation: 'positive',
        media: 'Clarín',
        support: 'Print',
        date: Date.new(2025, 1, 2),
        audience_size: 1_000,
        quotation: 120.5
      )
      neutral_news = create(
        :news,
        topic: topic,
        valuation: 'neutral',
        media: 'Clarín',
        support: 'Print',
        date: Date.new(2025, 1, 5),
        audience_size: 2_000,
        quotation: 80.25
      )
      negative_news = create(
        :news,
        topic: topic,
        valuation: 'negative',
        media: 'La Nación',
        support: 'Digital',
        date: Date.new(2025, 1, 1),
        audience_size: nil,
        quotation: 210.75
      )

      clipping = build(
        :clipping,
        topic: topic,
        news_ids: [positive_news.id, neutral_news.id, negative_news.id],
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 1, 7)
      )

      travel_to Time.zone.local(2025, 1, 10, 9, 30) do
        metrics = described_class.call(clipping)

        expect(metrics[:generated_at]).to eq(Time.current.iso8601)
        expect(metrics[:news_count]).to eq(3)
        expect(metrics[:date_range]).to eq(from: Date.new(2025, 1, 1), to: Date.new(2025, 1, 5))

        expect(metrics[:valuation]).to eq(
          positive: { count: 1, percentage: 33.33 },
          neutral: { count: 1, percentage: 33.33 },
          negative: { count: 1, percentage: 33.33 },
          total: 3
        )

        expect(metrics[:media_stats][:total]).to eq(3)
        expect(metrics[:media_stats][:items]).to contain_exactly(
          { key: 'Clarín', count: 2, percentage: 66.67 },
          { key: 'La Nación', count: 1, percentage: 33.33 }
        )

        expect(metrics[:support_stats][:total]).to eq(3)
        expect(metrics[:support_stats][:items]).to contain_exactly(
          { key: 'Print', count: 2, percentage: 66.67 },
          { key: 'Digital', count: 1, percentage: 33.33 }
        )

        expect(metrics[:audience]).to eq(
          total: 3_000,
          average: 1_500.0,
          max: { news_id: neutral_news.id, value: 2_000 }
        )

        expect(metrics[:quotation]).to eq(
          total: 411.5,
          average: 137.17,
          max: { news_id: negative_news.id, value: 210.75 }
        )

        expect(metrics[:crisis]).to be(true)
      end
    end

    it 'returns default values when there are no news ids' do
      clipping = build(:clipping, news_ids: [])

      travel_to Time.zone.local(2025, 1, 1, 12, 0) do
        metrics = described_class.call(clipping)

        expect(metrics[:generated_at]).to eq(Time.current.iso8601)
        expect(metrics[:news_count]).to eq(0)
        expect(metrics[:date_range]).to eq(from: nil, to: nil)
        expect(metrics[:valuation]).to eq(
          positive: { count: 0, percentage: 0.0 },
          neutral: { count: 0, percentage: 0.0 },
          negative: { count: 0, percentage: 0.0 },
          total: 0
        )
        expect(metrics[:media_stats]).to eq(total: 0, items: [])
        expect(metrics[:support_stats]).to eq(total: 0, items: [])
        expect(metrics[:audience]).to eq(total: nil, average: nil, max: nil)
        expect(metrics[:quotation]).to eq(total: nil, average: nil, max: nil)
        expect(metrics[:crisis]).to be(false)
      end
    end
  end
end
