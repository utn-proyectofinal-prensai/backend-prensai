# frozen_string_literal: true

# == Schema Information
#
# Table name: clippings
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  news_ids     :jsonb            not null
#  period_end   :date             not null
#  period_start :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :bigint           not null
#  topic_id     :bigint           not null
#
# Indexes
#
#  index_clippings_on_creator_id    (creator_id)
#  index_clippings_on_news_ids      (news_ids) USING gin
#  index_clippings_on_period_end    (period_end)
#  index_clippings_on_period_start  (period_start)
#  index_clippings_on_topic_id      (topic_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (topic_id => topics.id)
#
class Clipping < ApplicationRecord
  include Filterable

  belongs_to :creator, class_name: 'User'
  belongs_to :topic

  before_validation :normalize_news_ids

  attr_reader :invalid_news_ids

  validates :name, :period_start, :period_end, presence: true
  validate :period_end_not_before_start
  validate :news_ids_must_be_positive_integers
  validate :news_ids_must_exist

  scope :ordered, -> { order(created_at: :desc) }
  filter_scope :topic_id, ->(id) { where(topic_id: id) }
  filter_scope :news_ids, ->(ids) { where("#{table_name}.news_ids && ?", ids.to_json) }
  filter_scope :period_start, ->(date) { where(arel_table[:period_start].gteq(date)) }
  filter_scope :period_end, ->(date) { where(arel_table[:period_end].lteq(date)) }

  def news_count
    news_ids.size
  end

  private

  def normalize_news_ids
    normalized = []
    @invalid_news_ids = []

    Array.wrap(news_ids).each do |value|
      int = cast_positive_integer(value)
      int ? normalized << int : @invalid_news_ids << value
    end

    self.news_ids = normalized
  end

  def period_end_not_before_start
    return if period_start.blank? || period_end.blank?
    return unless period_end < period_start

    errors.add(:period_end, :before_period_start, message: 'must be on or after period start')
  end

  def news_ids_must_be_positive_integers
    return if invalid_news_ids.blank?

    errors.add(:news_ids, 'must contain positive integer IDs')
  end

  def news_ids_must_exist
    return if news_ids.blank?

    existing_ids = News.where(id: news_ids).pluck(:id)
    missing_ids = news_ids - existing_ids
    return if missing_ids.empty?

    errors.add(:news_ids, 'must reference existing news')
  end

  def cast_positive_integer(value)
    int = Integer(value, exception: false)
    int&.positive? ? int : nil
  rescue TypeError
    nil
  end
end
