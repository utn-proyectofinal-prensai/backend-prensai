# frozen_string_literal: true

# == Schema Information
#
# Table name: clippings
#
#  id             :bigint           not null, primary key
#  filters        :jsonb            not null
#  name           :string           not null
#  news_ids       :jsonb            not null
#  period_end     :date             not null
#  period_start   :date             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  created_by_id  :bigint           not null
#
# Indexes
#
#  index_clippings_on_created_by_id  (created_by_id)
#  index_clippings_on_filters       (filters) USING gin
#  index_clippings_on_news_ids      (news_ids) USING gin
#  index_clippings_on_period_end    (period_end)
#  index_clippings_on_period_start  (period_start)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
class Clipping < ApplicationRecord
  include Filterable

  belongs_to :creator, class_name: 'User', foreign_key: :created_by_id

  before_validation :normalize_news_ids!

  attr_reader :invalid_news_ids

  filter_scope :created_by_id, lambda { |value|
    ids = normalize_id_values(value)
    ids.present? ? where(created_by_id: ids) : all
  }
  filter_scope :period_start_from, lambda { |value|
    date = parse_date(value)
    date.present? ? where(arel_table[:period_start].gteq(date)) : all
  }
  filter_scope :period_end_to, lambda { |value|
    date = parse_date(value)
    date.present? ? where(arel_table[:period_end].lteq(date)) : all
  }
  filter_scope :filters_contains, lambda { |value|
    value_hash = normalize_jsonb_filter(value)
    value_hash.present? ? where("#{table_name}.filters @> ?", value_hash.to_json) : all
  }
  filter_scope :with_news_ids, lambda { |value|
    ids = normalize_news_ids(value)
    ids.present? ? where("#{table_name}.news_ids @> ?", ids.to_json) : all
  }

  validates :name, :period_start, :period_end, presence: true
  validate :period_end_cannot_be_before_period_start
  validate :news_ids_must_be_positive_integers

  scope :ordered, -> { order(created_at: :desc) }

  def news_count
    news_ids.size
  end

  private

  def normalize_news_ids!
    normalized_ids = []
    @invalid_news_ids = []

    Array(news_ids).each do |value|
      id = extract_id(value)

      if id.is_a?(Integer) && id.positive?
        normalized_ids << id
      else
        @invalid_news_ids << value unless value.nil?
      end
    end

    self.news_ids = normalized_ids
  end

  def extract_id(value)
    case value
    when Hash
      extract_id(value['id'] || value[:id])
    when String
      Integer(value, exception: false)
    when Integer
      value
    when Float
      value.to_i if value.positive?
    else
      nil
    end
  end

  def period_end_cannot_be_before_period_start
    return if period_start.blank? || period_end.blank?
    return unless period_end < period_start

    errors.add(:period_end, :before_period_start, message: 'must be on or after period start')
  end

  def news_ids_must_be_positive_integers
    return if invalid_news_ids.blank?

    errors.add(:news_ids, :invalid, message: 'must contain positive integer IDs')
  end

  class << self
    private

    def normalize_jsonb_filter(value)
      data = if defined?(ActionController::Parameters) && value.is_a?(ActionController::Parameters)
                value.to_unsafe_h
              elsif value.is_a?(Hash)
                value
              elsif value.is_a?(String)
                begin
                  JSON.parse(value)
                rescue JSON::ParserError
                  {}
                end
              else
                {}
              end

      data.each_with_object({}) do |(key, val), memo|
        memo[key.to_s] = val unless val.blank?
      end
    end

    def normalize_id_values(value)
      raw_values = if defined?(ActionController::Parameters) && value.is_a?(ActionController::Parameters)
                     value.to_unsafe_h.values
                   elsif value.is_a?(Hash)
                     value.values
                   else
                     Array(value)
                   end

      raw_values.filter_map do |raw|
        case raw
        when Integer
          raw if raw.positive?
        when String
          parsed = Integer(raw, exception: false)
          parsed.positive? ? parsed : nil
        when Float
          int = raw.to_i
          int.positive? ? int : nil
        else
          nil
        end
      end
    end

    def normalize_news_ids(value)
      normalize_id_values(value)
    end

    def parse_date(value)
      raw = extract_first_scalar(value)
      case raw
      when Date
        raw
      when Time, DateTime
        raw.to_date
      when String
        begin
          Date.parse(raw)
        rescue ArgumentError
          nil
        end
      else
        nil
      end
    end

    def extract_first_scalar(value)
      return value if scalar?(value)

      collection = if defined?(ActionController::Parameters) && value.is_a?(ActionController::Parameters)
                     value.to_unsafe_h.values
                   elsif value.is_a?(Hash)
                     value.values
                   elsif value.is_a?(Array)
                     value
                   else
                     Array(value)
                   end

      collection.find { |item| scalar?(item) }
    end

    def scalar?(value)
      value.is_a?(String) || value.is_a?(Numeric) || value.is_a?(Date) || value.is_a?(Time)
    end
  end
end
