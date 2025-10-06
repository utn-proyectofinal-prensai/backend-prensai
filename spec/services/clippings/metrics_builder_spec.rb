# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clippings::MetricsBuilder, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  describe '.call' do
    context 'when the clipping has associated news' do
      let(:topic) { create(:topic) }
      let(:news_items) do
        [
          create(
            :news,
            topic: topic,
            valuation: 'positive',
            media: 'Clarín',
            support: 'Print',
            date: Date.new(2025, 1, 2),
            audience_size: 1_000,
            quotation: 120.5
          ),
          create(
            :news,
            topic: topic,
            valuation: 'neutral',
            media: 'Clarín',
            support: 'Print',
            date: Date.new(2025, 1, 5),
            audience_size: 2_000,
            quotation: 80.25
          ),
          create(
            :news,
            topic: topic,
            valuation: 'negative',
            media: 'La Nación',
            support: 'Digital',
            date: Date.new(2025, 1, 1),
            audience_size: nil,
            quotation: 210.75
          )
        ]
      end
      let(:clipping) do
        create(
          :clipping,
          name: 'Metrics sample',
          start_date: Date.new(2025, 1, 1),
          end_date: Date.new(2025, 1, 7),
          topic: topic,
          creator: create(:user),
          news_ids: news_items.pluck(:id)
        )
      end
      let(:frozen_time) { Time.zone.local(2025, 1, 10, 9, 30) }
      let(:metrics) { travel_to(frozen_time) { described_class.call(clipping) } }

      before { allow(clipping.topic).to receive(:crisis?).and_return(true) }

      it 'sets generated_at with the current time' do
        expect(metrics[:generated_at]).to eq(frozen_time.iso8601)
      end

      it 'counts the news used for the clipping' do
        expect(metrics[:news_count]).to eq(3)
      end

      it 'reports the date range covered by the news' do
        expect(metrics[:date_range]).to eq(from: Date.new(2025, 1, 1), to: Date.new(2025, 1, 5))
      end

      it 'builds the valuation breakdown' do
        expect(metrics[:valuation]).to eq(
          positive: { count: 1, percentage: 33.33 },
          neutral: { count: 1, percentage: 33.33 },
          negative: { count: 1, percentage: 33.33 },
          total: 3
        )
      end

      it 'groups metrics by media outlet' do
        expect(metrics[:media_stats]).to eq(
          total: 3,
          items: [
            { key: 'Clarín', count: 2, percentage: 66.67 },
            { key: 'La Nación', count: 1, percentage: 33.33 }
          ]
        )
      end

      it 'groups metrics by support type' do
        expect(metrics[:support_stats]).to eq(
          total: 3,
          items: [
            { key: 'Print', count: 2, percentage: 66.67 },
            { key: 'Digital', count: 1, percentage: 33.33 }
          ]
        )
      end

      it 'aggregates audience values' do
        neutral_news = news_items.find { |news| news.valuation == 'neutral' }
        expect(metrics[:audience]).to eq(
          total: 3_000,
          average: 1_500.0,
          max: { news_id: neutral_news.id, value: 2_000 }
        )
      end

      it 'aggregates quotation values' do
        negative_news = news_items.find { |news| news.valuation == 'negative' }
        expect(metrics[:quotation]).to eq(
          total: 411.5,
          average: 137.17,
          max: { news_id: negative_news.id, value: 210.75 }
        )
      end

      it 'reflects the crisis status of the associated topic' do
        expect(metrics[:crisis]).to be(true)
      end
    end
  end
end
