# frozen_string_literal: true

# == Schema Information
#
# Table name: clippings
#
#  id         :bigint           not null, primary key
#  end_date   :date             not null
#  metrics    :jsonb            not null
#  name       :string           not null
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
#  index_clippings_on_metrics     (metrics) USING gin
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
  belongs_to :reviewer, class_name: 'User', optional: true

  has_many :clipping_news, dependent: :destroy
  has_many :news, through: :clipping_news
  has_one :report, class_name: 'ClippingReport', dependent: :destroy, inverse_of: :clipping

  before_validation :normalize_news_ids
  before_save :assign_metrics

  validates :name, presence: true, length: { minimum: 3, maximum: 255 }
  validates :start_date, :end_date, presence: true
  validate :end_date_not_before_start_date
  validate :must_have_at_least_one_news
  validate :topic_must_be_enabled
  validates_with ClippingNewsValidator

  scope :ordered, -> { order(created_at: :desc) }
  filter_scope :topic_id, ->(id) { where(topic_id: id) }
  filter_scope :news_ids, lambda { |ids|
    sanitized_ids = Array.wrap(ids).map(&:to_i).select(&:positive?)
    return all if sanitized_ids.empty?

    joins(:clipping_news).where(clipping_news: { news_id: sanitized_ids }).distinct
  }
  filter_scope :start_date, ->(date) { where(arel_table[:start_date].gteq(date)) }
  filter_scope :end_date, ->(date) { where(arel_table[:end_date].lteq(date)) }

  def refresh_metrics!
    update!(metrics: Clippings::MetricsBuilder.call(self))
  end

  private

  def assign_metrics
    self.metrics = Clippings::MetricsBuilder.call(self)
  end

  def normalize_news_ids
    return unless news_ids.is_a?(Array)

    sanitized_ids = news_ids.map(&:to_i).select(&:positive?).uniq
    self.news_ids = sanitized_ids
  end

  def end_date_not_before_start_date
    return if start_date.blank? || end_date.blank?
    return unless end_date < start_date

    errors.add(:end_date, :before_start_date)
  end

  def must_have_at_least_one_news
    return if news_ids.present? && news_ids.any?

    errors.add(:news_ids, :blank)
  end

  def topic_must_be_enabled
    return if topic.blank? || topic.enabled?

    errors.add(:topic, :disabled)
  end
end
