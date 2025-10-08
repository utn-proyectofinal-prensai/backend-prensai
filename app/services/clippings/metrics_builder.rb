# frozen_string_literal: true

module Clippings
  class MetricsBuilder
    def self.call(clipping)
      new(clipping).call
    end

    def initialize(clipping)
      @clipping = clipping
      @news_scope = News.where(id: clipping.news_ids)
    end

    def call
      {
        generated_at: Time.current.iso8601,
        date_range: date_range,
        news_count: news_count,
        valuation: valuation_stats,
        media_stats: collection_stats(:media),
        support_stats: collection_stats(:support),
        mention_stats: mention_stats,
        audience: numeric_field_stats(:audience_size),
        quotation: numeric_field_stats(:quotation),
        crisis: clipping.topic&.crisis? || false
      }
    end

    private

    attr_reader :clipping, :news_scope

    def news_count
      @news_count ||= news_scope.count
    end

    def date_range
      return { from: nil, to: nil } if news_count.zero?

      dates = news_scope.pick(Arel.sql('MIN(date), MAX(date)'))
      { from: dates[0], to: dates[1] }
    end

    def valuation_stats
      counts = news_scope.group(:valuation).count.transform_keys(&:to_s)

      {
        positive: valuation_breakdown(counts['positive']),
        neutral: valuation_breakdown(counts['neutral']),
        negative: valuation_breakdown(counts['negative']),
        total: news_count
      }
    end

    def collection_stats(field)
      counts = news_scope.where.not(field => [nil, '']).group(field).count
      total = counts.values.sum

      {
        total: total,
        items: counts
          .sort_by { |key, count| [-count, key.to_s.downcase] }
          .map { |key, count| build_collection_item(key, count, total) }
      }
    end

    def mention_stats
      counts = MentionNews
               .joins(:mention)
               .where(news_id: news_scope.select(:id))
               .group('mentions.id', 'mentions.name')
               .count

      total = counts.values.sum

      {
        total: total,
        items: counts
          .sort_by { |(_, name), count| [-count, name.downcase] }
          .map { |(id, name), count| build_mention_item(id, name, count, total) }
      }
    end

    def numeric_field_stats(field)
      values = news_scope.where.not(field => nil).pluck(:id, field)
      return { total: nil, average: nil, max: nil } if values.empty?

      typed_values = values.map { |id, val| [id, cast_to_numeric(field, val)] }
      total = typed_values.sum(&:last)
      max_news_id, max_value = typed_values.max_by(&:last)

      {
        total: total,
        average: (total.to_f / typed_values.size).round(2),
        max: { news_id: max_news_id, value: max_value }
      }
    end

    def valuation_breakdown(count)
      count = count.to_i
      { count: count, percentage: calculate_percentage(count, news_count) }
    end

    def build_collection_item(key, count, total)
      {
        key: key,
        count: count,
        percentage: calculate_percentage(count, total)
      }
    end

    def build_mention_item(mention_id, name, count, total)
      {
        mention_id: mention_id,
        name: name,
        count: count,
        percentage: calculate_percentage(count, total)
      }
    end

    def calculate_percentage(count, total)
      return 0.0 if total.zero?

      ((count.to_f / total) * 100).round(2)
    end

    def cast_to_numeric(field, value)
      field == :audience_size ? value.to_i : value.to_f
    end
  end
end
