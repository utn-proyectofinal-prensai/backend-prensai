# frozen_string_literal: true

module Metrics
  class SnapshotRefreshJob < ApplicationJob
    queue_as :default

    def perform(context: MetricSnapshot::GLOBAL_CONTEXT)
      MetricSnapshot.create!(
        context: context,
        generated_at: Time.current,
        data: build_payload(context)
      )
    end

    private

    def build_payload(context)
      {
        context: context,
        generated_from: {
          model: 'news',
          timestamp_column: 'created_at',
          timezone: Time.zone.name
        },
        news_totals: {},
        news_trend: [],
        top_topics: [],
        top_mentions: [],
        sentiment_split: {}
      }
    end
  end
end
