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
#  link             :string
#  management       :string
#  media            :string           not null
#  plain_text       :text
#  political_factor :string
#  publication_type :string           not null
#  quotation        :decimal(10, 2)   default(0.0)
#  section          :string
#  support          :string           not null
#  title            :string           not null
#  valuation        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  topic_id         :bigint
#
# Indexes
#
#  index_news_on_date              (date)
#  index_news_on_media             (media)
#  index_news_on_publication_type  (publication_type)
#  index_news_on_topic_id          (topic_id)
#  index_news_on_valuation         (valuation)
#
# Foreign Keys
#
#  fk_rails_...  (topic_id => topics.id)
#
class News < ApplicationRecord
  belongs_to :topic, optional: true

  has_many :mention_news, dependent: :destroy
  has_many :mentions, through: :mention_news

  validates :title, :publication_type, :date, :support, :media, presence: true

  enum :valuation, { positive: 'positive', neutral: 'neutral', negative: 'negative' }, prefix: true

  scope :ordered, -> { order(date: :desc) }

  after_create :check_topic_crisis
  after_update :check_topic_crisis, if: -> { saved_change_to_valuation? || saved_change_to_topic_id? }
  after_destroy :check_topic_crisis

  private

  def check_topic_crisis
    if topic_id_before_last_save.present? && topic_id_before_last_save != topic_id
      Topic.find(topic_id_before_last_save).check_crisis!
    end
    topic&.check_crisis!
  end
end
