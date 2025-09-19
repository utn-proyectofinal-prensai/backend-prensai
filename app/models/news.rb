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
  belongs_to :topic, optional: true
  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :reviewer, class_name: 'User', optional: true

  has_many :mention_news, dependent: :destroy
  has_many :mentions, through: :mention_news

  validates :title, :date, :support, :media, :link, presence: true

  enum :valuation, { positive: 'positive', neutral: 'neutral', negative: 'negative' }, prefix: true

  scope :ordered, -> { order(created_at: :desc) }

  after_create :check_topic_crisis
  after_update :check_topic_crisis, if: -> { saved_change_to_valuation? || saved_change_to_topic_id? }
  after_destroy :check_topic_crisis

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
end
