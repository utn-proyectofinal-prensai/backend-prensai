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
#  creator_id  :bigint
#  reviewer_id :bigint
#
# Indexes
#
#  index_clipping_reports_on_clipping_id  (clipping_id) UNIQUE
#  index_clipping_reports_on_creator_id   (creator_id)
#  index_clipping_reports_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (clipping_id => clippings.id)
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (reviewer_id => users.id)
#
class ClippingReport < ApplicationRecord
  belongs_to :clipping
  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :reviewer, class_name: 'User', optional: true

  validates :content, presence: true
  validates :metadata, presence: true

  def manually_edited?
    reviewer.present?
  end
end
