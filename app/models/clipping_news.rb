# frozen_string_literal: true

# == Schema Information
#
# Table name: clipping_news
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  clipping_id :bigint           not null
#  news_id     :bigint           not null
#
# Indexes
#
#  index_clipping_news_on_clipping_id              (clipping_id)
#  index_clipping_news_on_clipping_id_and_news_id  (clipping_id,news_id) UNIQUE
#  index_clipping_news_on_news_id                  (news_id)
#
# Foreign Keys
#
#  fk_rails_...  (clipping_id => clippings.id)
#  fk_rails_...  (news_id => news.id)
#
class ClippingNews < ApplicationRecord
  belongs_to :clipping
  belongs_to :news

  validates :news_id, uniqueness: { scope: :clipping_id }

  after_commit :refresh_clipping_metrics, on: %i[create destroy]

  private

  def refresh_clipping_metrics
    return if clipping.destroyed?

    clipping.refresh_metrics!
  end
end
