# == Schema Information
#
# Table name: topics
#
#  id          :bigint           not null, primary key
#  description :text
#  enabled     :boolean          default(TRUE)
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_topics_on_name  (name) UNIQUE
#
class Topic < ApplicationRecord
  has_many :news, dependent: :restrict_with_error
  
  validates :name, presence: true, uniqueness: true
  
  scope :ordered, -> { order(:name) }
end
