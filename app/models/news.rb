# frozen_string_literal: true

# == Schema Information
#
# Table name: news
#
#  id               :bigint           not null, primary key
#  audience_size    :integer
#  author           :string
#  date             :date             not null
#  interviewee      :string
#  link             :string           not null
#  media            :string           not null
#  plain_text       :text
#  political_factor :string
#  publication_type :string
#  quotation        :decimal(10, 2)   default(0.0)
#  section          :string
#  support          :string           not null
#  title            :string           not null
#  valuation        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  creator_id       :bigint
#  reviewer_id      :bigint
#  topic_id         :bigint
#
# Indexes
#
#  index_news_on_creator_id        (creator_id)
#  index_news_on_date              (date)
#  index_news_on_link              (link) UNIQUE
#  index_news_on_media             (media)
#  index_news_on_publication_type  (publication_type)
#  index_news_on_reviewer_id       (reviewer_id)
#  index_news_on_topic_id          (topic_id)
#  index_news_on_valuation         (valuation)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (reviewer_id => users.id)
#  fk_rails_...  (topic_id => topics.id)
#
class News < ApplicationRecord
  include Filterable
  belongs_to :topic, optional: true
  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :reviewer, class_name: 'User', optional: true

  has_many :mention_news, dependent: :destroy
  has_many :mentions, through: :mention_news
  has_many :clipping_news, dependent: :destroy
  has_many :clippings, through: :clipping_news

  validates :title, :date, :support, :media, :link, presence: true

  enum :valuation, { positive: 'positive', neutral: 'neutral', negative: 'negative' }, prefix: true

  METRIC_ATTRIBUTES = %i[valuation media support date audience_size quotation].freeze

  scope :ordered, -> { order(created_at: :desc) }
  filter_scope :topic_id, ->(id) { where(topic_id: id) }
  filter_scope :start_date, ->(date) { where(arel_table[:date].gteq(date)) }
  filter_scope :end_date, ->(date) { where(arel_table[:date].lteq(date)) }
  filter_scope :media, ->(media) { where(media: media) }
  filter_scope :publication_type, ->(type) { where(publication_type: type) }
  filter_scope :valuation, ->(valuation) { where(valuation: valuation) }

  after_create :check_topic_crisis
  before_update :prevent_topic_change_when_clipped, if: :will_save_change_to_topic_id?
  before_update :ensure_date_within_clipping_bounds, if: :will_save_change_to_date?
  after_update :check_topic_crisis, if: -> { saved_change_to_valuation? || saved_change_to_topic_id? }
  after_destroy :check_topic_crisis
  after_commit :refresh_related_clippings_metrics, on: :update, if: :metrics_affecting_previous_changes?

  def requires_manual_review?
    manual_review_fields.include?('REVISAR MANUAL') || required_fields.any?(&:nil?)
  end

  def crisis?
    topic&.crisis?
  end

  private

  def manual_review_fields
    [publication_type, political_factor, interviewee]
  end

  def required_fields
    [valuation, topic]
  end

  def check_topic_crisis
    if topic_id_before_last_save.present? && topic_id_before_last_save != topic_id
      Topic.find(topic_id_before_last_save).check_crisis!
    end
    topic&.check_crisis!
  end

  def refresh_related_clippings_metrics
    return unless clippings.exists?

    clippings.find_each(&:refresh_metrics!)
  end

  def metrics_affecting_previous_changes?
    changed_keys = previous_changes.keys.map(&:to_sym)
    changed_keys.intersect?(METRIC_ATTRIBUTES)
  end

  def prevent_topic_change_when_clipped
    previous_topic_id = topic_id_in_database
    return if previous_topic_id.blank?

    return unless clipping_news.joins(:clipping).exists?(clippings: { topic_id: previous_topic_id })

    errors.add(:topic_id, 'cannot be changed while the news belongs to clippings for the current topic')
    throw :abort
  end

  def ensure_date_within_clipping_bounds
    violating = clipping_news.joins(:clipping)
    return unless violating.exists?(['clippings.start_date > ? OR clippings.end_date < ?', date, date])

    errors.add(:date, 'cannot move outside the date range of linked clippings')
    throw :abort
  end
end
