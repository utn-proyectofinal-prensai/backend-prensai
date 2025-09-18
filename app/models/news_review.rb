# frozen_string_literal: true

# == Schema Information
#
# Table name: news_reviews
#
#  id            :bigint           not null, primary key
#  changeset     :jsonb            not null
#  news_snapshot :jsonb            not null
#  notes         :text
#  reviewed_at   :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  news_id       :bigint           not null
#  reviewer_id   :bigint           not null
#
# Indexes
#
#  index_news_reviews_on_news_id      (news_id)
#  index_news_reviews_on_reviewed_at  (reviewed_at)
#  index_news_reviews_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (news_id => news.id)
#  fk_rails_...  (reviewer_id => users.id)
#
class NewsReview < ApplicationRecord
  belongs_to :news
  belongs_to :reviewer, class_name: 'User'

  validates :changeset, presence: true
  validates :news_snapshot, presence: true

  scope :recent_first, -> { order(reviewed_at: :desc, created_at: :desc) }
end
