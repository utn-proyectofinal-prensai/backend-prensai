# frozen_string_literal: true

# == Schema Information
#
# Table name: mention_news
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  mention_id :bigint           not null
#  news_id    :bigint           not null
#
# Indexes
#
#  index_mention_news_on_mention_id              (mention_id)
#  index_mention_news_on_mention_id_and_news_id  (mention_id,news_id) UNIQUE
#  index_mention_news_on_news_id                 (news_id)
#
# Foreign Keys
#
#  fk_rails_...  (mention_id => mentions.id)
#  fk_rails_...  (news_id => news.id)
#
class MentionNews < ApplicationRecord
  belongs_to :mention
  belongs_to :new

  validates :mention_id, uniqueness: { scope: :new_id }
end
