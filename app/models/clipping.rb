# frozen_string_literal: true

# == Schema Information
#
# Table name: clippings
#
#  id           :bigint           not null, primary key
#  filters      :jsonb            not null
#  name         :string           not null
#  news_ids     :jsonb            not null
#  period_end   :date             not null
#  period_start :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :bigint           not null
#
# Indexes
#
#  index_clippings_on_creator_id    (creator_id)
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
  belongs_to :creator, class_name: 'User'

  before_validation :normalize_news_ids!

  attr_reader :invalid_news_ids

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
end
