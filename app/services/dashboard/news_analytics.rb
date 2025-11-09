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
      counts_by_date = normalized_trend_counts

      Dashboard::TimeWindow.dates_for(window_range).map do |date|
        { date: date.iso8601, count: counts_by_date.fetch(date, 0) }
      end
    end

    def valuation_counts
      counts = weekly_scope.group(:valuation).count
      result = News.valuations.keys.index_with { |valuation| counts[valuation] || 0 }

      unassigned = counts[nil].to_i
      result['unassigned'] = unassigned if unassigned.positive?
      result
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

    def normalized_trend_counts
      weekly_scope
        .group(trend_grouping_expression)
        .order(trend_grouping_expression.asc)
        .count
        .each_with_object({}) do |(date_value, total), result|
          date = date_value.is_a?(Date) ? date_value : Date.parse(date_value.to_s)
          result[date] = total
        end
    end

    def trend_grouping_expression
      Arel.sql(localized_created_at_date_sql)
    end

    def trend_range
      @trend_range ||= Dashboard::TimeWindow.last_days(trend_days, now)
    end

    def localized_created_at_date_sql
      # `created_at` is persisted in UTC; convert to the configured Time.zone before truncating
      column = "#{News.quoted_table_name}.#{News.connection.quote_column_name('created_at')}"
      utc_zone = News.connection.quote('UTC')
      local_zone = News.connection.quote(Time.zone.tzinfo&.name || Time.zone.name)

      "DATE(((#{column}) AT TIME ZONE #{utc_zone}) AT TIME ZONE #{local_zone})"
    end
  end
end
