# == Schema Information
#
# Table name: ai_configurations
#
#  id           :bigint           not null, primary key
#  description  :text
#  display_name :string           not null
#  enabled      :boolean          default(TRUE), not null
#  key          :string           not null
#  value        :jsonb
#  value_type   :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_ai_configurations_on_enabled  (enabled)
#  index_ai_configurations_on_key      (key) UNIQUE
#
class AiConfiguration < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :display_name, :value_type, presence: true

  scope :enabled, -> { where(enabled: true) }
  scope :ordered, -> { order(:display_name) }

  RANSACK_ATTRIBUTES = %w[id key display_name enabled created_at updated_at].freeze

  def self.editable_configurations
    enabled.ordered.map do |config|
      {
        key: config.key,
        display_name: config.display_name,
        description: config.description,
        value_type: config.value_type,
        current_value: config.value,
        enabled: config.enabled
      }
    end
  end

  def self.get_value(key)
    find_by(key: key)&.value
  end

  def value
    cast_value_by_type
  end

  def value=(new_value)
    super(cast_input_value(new_value))
  end

  private

  def cast_value_by_type
    case value_type
    when 'array' then super || []
    when 'string' then super || ''
    when 'object' then super || {}
    else super
    end
  end

  def cast_input_value(new_value)
    case value_type
    when 'array' then new_value.is_a?(Array) ? new_value : []
    when 'string' then new_value.to_s
    when 'object' then new_value.is_a?(Hash) ? new_value : {}
    else new_value
    end
  end
end
