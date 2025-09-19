# frozen_string_literal: true

# == Schema Information
#
# Table name: topics
#
#  id          :bigint           not null, primary key
#  crisis      :boolean          default(FALSE), not null
#  description :text
#  enabled     :boolean          default(TRUE), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_topics_on_name  (name) UNIQUE
#
class Topic < ApplicationRecord
  include Filterable

  has_many :news, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }
  filter_scope :enabled, ->(enabled) { where(enabled: enabled) }

  def check_crisis!
    update!(crisis: should_be_crisis?)
  end

  def default?
    AiConfiguration.get_value('default_topic') == id
  end

  private

  def should_be_crisis?
    default? ? false : news.valuation_negative.count >= 5
  end
end
