# frozen_string_literal: true

# == Schema Information
#
# Table name: clipping_reports
#
#  id          :bigint           not null, primary key
#  content     :text             not null
#  metadata    :jsonb            not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  clipping_id :bigint           not null
#
# Indexes
#
#  index_clipping_reports_on_clipping_id  (clipping_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (clipping_id => clippings.id)
#
class ClippingReport < ApplicationRecord
  belongs_to :clipping

  validates :content, presence: true
  validates :metadata, presence: true
end
