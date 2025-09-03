# frozen_string_literal: true

# == Schema Information
#
# Table name: mentions
#
#  id         :bigint           not null, primary key
#  enabled    :boolean          default(TRUE), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_mentions_on_name  (name) UNIQUE
#

class Mention < ApplicationRecord
  include Filterable

  has_many :mention_news, dependent: :restrict_with_exception
  has_many :news, through: :mention_news

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }
  filter_scope :enabled, ->(enabled) { where(enabled: enabled) }
end
