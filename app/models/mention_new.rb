# == Schema Information
#
# Table name: mention_news
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  mention_id :bigint           not null
#  new_id     :bigint           not null
#
# Indexes
#
#  index_mention_news_on_mention_id             (mention_id)
#  index_mention_news_on_mention_id_and_new_id  (mention_id,new_id) UNIQUE
#  index_mention_news_on_new_id                 (new_id)
#
# Foreign Keys
#
#  fk_rails_...  (mention_id => mentions.id)
#  fk_rails_...  (new_id => news.id)
#
class MentionNew < ApplicationRecord
  belongs_to :mention
  belongs_to :new
  
  validates :mention_id, uniqueness: { scope: :new_id }
end
