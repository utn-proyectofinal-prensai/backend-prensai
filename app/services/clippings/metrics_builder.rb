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
        audience: numeric_stats(:audience_size),
        quotation: numeric_stats(:quotation),
        crisis: crisis_flag
      }
    end

    private

    attr_reader :clipping, :news_scope

    def news_count
      @news_count ||= news_scope.count
    end

    def date_range
      return { from: nil, to: nil } if news_count.zero?

      {
        from: news_scope.minimum(:date),
        to: news_scope.maximum(:date)
      }
    end

    def valuation_stats
      counts = news_scope.group(:valuation).count.transform_keys { |key| key&.to_s }
      total = news_count

      {
        positive: breakdown_for(counts['positive'], total),
        neutral: breakdown_for(counts['neutral'], total),
        negative: breakdown_for(counts['negative'], total),
        total: total
      }
    end

    def collection_stats(field)
      counts = news_scope.where.not(field => [nil, '']).group(field).count
      total = counts.values.sum

      items = counts.sort_by { |key, count| [-count, key.to_s.downcase] }.map do |key, count|
        {
          key: key,
          count: count,
          percentage: percentage(count, total)
        }
      end

      {
        total: total,
        items: items
      }
    end

    def numeric_stats(field)
      values = news_scope.where.not(field => nil).pluck(:id, field)
      return { total: nil, average: nil, max: nil } if values.empty?

      numeric_values = values.map { |id, value| [id, cast_numeric(field, value)] }
      total_value = numeric_values.sum { |_id, value| value }
      count = numeric_values.size
      max_id, max_value = numeric_values.max_by { |_id, value| value }

      {
        total: total_value,
        average: (total_value.to_f / count).round(2),
        max: { news_id: max_id, value: max_value }
      }
    end

    def breakdown_for(count, total)
      count = count.to_i

      {
        count: count,
        percentage: percentage(count, total)
      }
    end

    def percentage(count, total)
      return 0.0 if total.zero?

      ((count.to_f / total) * 100).round(2)
    end

    def cast_numeric(field, value)
      field == :audience_size ? value.to_i : value.to_f
    end

    def crisis_flag
      clipping.topic&.crisis? || false
    end
  end
end
