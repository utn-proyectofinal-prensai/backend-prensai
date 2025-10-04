# frozen_string_literal: true

# == Schema Information
#
# Table name: clippings
#
#  id         :bigint           not null, primary key
#  end_date   :date             not null
#  name       :string           not null
#  news_ids   :jsonb            not null
#  start_date :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  creator_id :bigint           not null
#  topic_id   :bigint           not null
#
# Indexes
#
#  index_clippings_on_creator_id  (creator_id)
#  index_clippings_on_end_date    (end_date)
#  index_clippings_on_news_ids    (news_ids) USING gin
#  index_clippings_on_start_date  (start_date)
#  index_clippings_on_topic_id    (topic_id)
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

  validates :name, :start_date, :end_date, presence: true
  validate :end_date_not_before_start_date
  validate :news_ids_must_be_positive_integers
  validate :news_ids_must_exist

  scope :ordered, -> { order(created_at: :desc) }
  filter_scope :topic_id, ->(id) { where(topic_id: id) }
  filter_scope :news_ids, lambda { |ids|
    # Use @> operator with OR to leverage GIN index on JSONB array
    # Each condition checks if news_ids contains at least one specific ID
    return all if ids.blank?

    sanitized_ids = ids.map(&:to_i)
    conditions = sanitized_ids.map { "#{table_name}.news_ids @> ?" }
    values = sanitized_ids.map { |id| [id].to_json }

    where(conditions.join(' OR '), *values)
  }
  filter_scope :start_date, ->(date) { where(arel_table[:start_date].gteq(date)) }
  filter_scope :end_date, ->(date) { where(arel_table[:end_date].lteq(date)) }

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

  def end_date_not_before_start_date
    return if start_date.blank? || end_date.blank?
    return unless end_date < start_date

    errors.add(:end_date, :before_start_date, message: 'must be on or after start date')
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
