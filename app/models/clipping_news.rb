# frozen_string_literal: true

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
