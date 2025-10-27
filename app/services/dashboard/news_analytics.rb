# frozen_string_literal: true

module Dashboard
  class NewsAnalytics
    DEFAULT_TREND_DAYS = 7
    DEFAULT_TOP_LIMIT = 5

    def initialize(scope: News.all, now: Time.zone.now, trend_days: DEFAULT_TREND_DAYS, top_limit: DEFAULT_TOP_LIMIT)
      @scope = scope
      @now = now
      @trend_days = trend_days
      @top_limit = top_limit
    end

    def range
      {
        from: window_range.begin.to_date.iso8601,
        to: window_range.end.to_date.iso8601
      }
    end

    def news_summary
      {
        count: weekly_scope.count,
        valuation: valuation_counts,
        trend: trend
      }
    end

    def topics_summary
      {
        count_unique: weekly_scope.with_topic.distinct.count(:topic_id),
        top: top_topics
      }
    end

    def mentions_summary
      {
        count_unique: mention_scope.distinct.count('mentions.id'),
        top: top_mentions
      }
    end

    def window_range
      trend_range
    end

    private

    attr_reader :scope, :now, :trend_days, :top_limit

    def weekly_scope
      @weekly_scope ||= scope.processed_between(window_range)
    end

    def trend
      counts = weekly_scope
               .group(Arel.sql('DATE(created_at)'))
               .order(Arel.sql('DATE(created_at) ASC'))
               .count

      counts_by_date = counts.to_h do |date_value, total|
        date = date_value.is_a?(Date) ? date_value : Date.parse(date_value.to_s)
        [date, total]
      end

      Dashboard::TimeWindow.dates_for(window_range).map do |date|
        { date: date.iso8601, count: counts_by_date[date] || 0 }
      end
    end

    def valuation_counts
      counts = weekly_scope.group(:valuation).count

      News.valuations.keys.index_with { |valuation|
        counts[valuation] || 0
      }.tap do |result|
        unassigned = counts[nil].to_i
        result['unassigned'] = unassigned if unassigned.positive?
      end
    end

    def top_topics
      topic_name = Topic.arel_table[:name]

      weekly_scope
        .with_topic
        .joins(:topic)
        .group('topics.id', 'topics.name')
        .order(Arel.sql('COUNT(*) DESC'), topic_name.asc)
        .limit(top_limit)
        .pluck('topics.name', Arel.sql('COUNT(*) AS total'))
        .map { |name, total| { name: name, news_count: total } }
    end

    def top_mentions
      mention_name = Mention.arel_table[:name]

      mention_scope
        .group('mentions.id', 'mentions.name')
        .order(Arel.sql('COUNT(*) DESC'), mention_name.asc)
        .limit(top_limit)
        .pluck('mentions.name', Arel.sql('COUNT(*) AS total'))
        .map { |name, total| { entity: name, count: total } }
    end

    def mention_scope
      Mention.joins(:news).merge(weekly_scope)
    end

    def trend_range
      @trend_range ||= Dashboard::TimeWindow.last_days(trend_days, now)
    end
  end
end
