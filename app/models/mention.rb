# frozen_string_literal: true

# == Schema Information
#
# Table name: mentions
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_mentions_on_name  (name) UNIQUE
#

class Mention < ApplicationRecord
  has_many :mention_news, dependent: :destroy
  has_many :news, through: :mention_news

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }
end
