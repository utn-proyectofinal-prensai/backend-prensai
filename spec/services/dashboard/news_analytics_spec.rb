# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::NewsAnalytics do
  let(:now) { Time.zone.local(2024, 3, 12, 12, 0, 0) }

  before { travel_to(now) }

  describe '#range' do
    it 'returns the ISO8601 boundaries for the configured window in the local time zone' do
      analytics = described_class.new(now: now, trend_days: 2)

      expect(analytics.range).to eq(
        from: (now - 2.days).beginning_of_day.to_date.iso8601,
        to: now.end_of_day.to_date.iso8601
      )
    end
  end

  describe '#news_summary' do
    subject(:summary) { described_class.new(now: now, trend_days: 1).news_summary }

    let!(:yesterday_news) do
      create(:news, created_at: now.beginning_of_day - 12.hours, valuation: 'positive')
    end
    let!(:today_neutral) { create(:news, created_at: now - 4.hours, valuation: 'neutral') }
    let!(:today_without_valuation) { create(:news, created_at: now - 30.minutes, valuation: nil) }
    let!(:out_of_range_news) { create(:news, created_at: now - 3.days, valuation: 'negative') }

    it 'only counts records within the window and groups by local day' do
      expect(summary[:count]).to eq(3)
      expect(summary[:valuation]).to include(
        'positive' => 1,
        'neutral' => 1,
        'negative' => 0,
        'unassigned' => 1
      )

      expected_trend = [
        { date: (now - 1.day).to_date.iso8601, count: 1 },
        { date: now.to_date.iso8601, count: 2 }
      ]

      expect(summary[:trend]).to eq(expected_trend)
    end
  end

  describe '#topics_summary' do
    subject(:summary) { described_class.new(now: now, top_limit: 2).topics_summary }

    let!(:topic_alpha)   { create(:topic, name: 'Alpha') }
    let!(:topic_bravo)   { create(:topic, name: 'Bravo') }
    let!(:topic_charlie) { create(:topic, name: 'Charlie') }

    before do
      create_list(:news, 2, topic: topic_bravo, created_at: now - 2.hours)
      create_list(:news, 2, topic: topic_charlie, created_at: now - 3.hours)
      create(:news, topic: topic_alpha, created_at: now - 4.hours)
      create(:news, topic: nil, created_at: now - 1.hour) # ignored because it lacks topic
    end

    it 'returns the number of distinct topics and the top ones ordered by count then name' do
      expect(summary[:count_unique]).to eq(3)
      expect(summary[:top]).to eq([
                                    { name: 'Bravo', news_count: 2 },
                                    { name: 'Charlie', news_count: 2 }
                                  ])
    end
  end

  describe '#mentions_summary' do
    subject(:summary) { described_class.new(now: now, top_limit: 3).mentions_summary }

    let!(:mention_amber)   { create(:mention, name: 'Amber') }
    let!(:mention_bravo)   { create(:mention, name: 'Bravo') }
    let!(:mention_charlie) { create(:mention, name: 'Charlie') }

    before do
      news_one = create(:news, created_at: now - 1.hour)
      news_one.mentions << mention_bravo

      news_two = create(:news, created_at: now - 2.hours)
      news_two.mentions << [mention_bravo, mention_amber]

      news_three = create(:news, created_at: now - 3.hours)
      news_three.mentions << mention_charlie

      old_news = create(:news, created_at: now - 10.days)
      old_news.mentions << mention_charlie
    end

    it 'counts mentions within the window and orders ties alphabetically' do
      expect(summary[:count_unique]).to eq(3)
      expect(summary[:top]).to eq([
                                    { entity: 'Bravo', count: 2 },
                                    { entity: 'Amber', count: 1 },
                                    { entity: 'Charlie', count: 1 }
                                  ])
    end
  end
end
