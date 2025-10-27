# frozen_string_literal: true

module Dashboard
  class SnapshotBuilder
    DEFAULT_TREND_DAYS = Dashboard::NewsAnalytics::DEFAULT_TREND_DAYS
    DEFAULT_TOP_LIMIT = Dashboard::NewsAnalytics::DEFAULT_TOP_LIMIT

    def initialize(context: DashboardSnapshot::GLOBAL_CONTEXT, trend_days: DEFAULT_TREND_DAYS,
                   top_limit: DEFAULT_TOP_LIMIT, now: Time.zone.now)
      @context = context
      @trend_days = trend_days
      @top_limit = top_limit
      @now = now
    end

    def call
      {
        meta: meta_data,
        news: analytics.news_summary,
        topics: analytics.topics_summary,
        mentions: analytics.mentions_summary,
        clippings: clippings_summary,
        reports: reports_summary
      }
    end

    private

    attr_reader :context, :trend_days, :top_limit, :now

    def analytics
      @analytics ||= Dashboard::NewsAnalytics.new(
        scope: scope_for_context,
        now: now,
        trend_days: trend_days,
        top_limit: top_limit
      )
    end

    def meta_data
      {
        range: analytics.range,
        generated_at: now.iso8601
      }
    end

    def clippings_summary
      {
        count: Clipping.where(created_at: analytics.window_range).count
      }
    end

    def reports_summary
      {
        count: ClippingReport.where(created_at: analytics.window_range).count
      }
    end

    def scope_for_context
      # Cuando existan más contextos (ej. organizaciones), resolveremos aquí la relación.
      News.all
    end
  end
end
