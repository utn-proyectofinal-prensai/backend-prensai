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
class New < ApplicationRecord
  belongs_to :topic, optional: true
  
  has_many :mention_news, dependent: :destroy
  has_many :mentions, through: :mention_news
  
  validates :title, :publication_type, :date, :support, :media, presence: true
  validates :mentions, length: { maximum: 5 }
end
