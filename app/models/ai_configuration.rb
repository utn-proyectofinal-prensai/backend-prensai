# == Schema Information
#
# Table name: ai_configurations
#
#  id             :bigint           not null, primary key
#  description    :text
#  display_name   :string           not null
#  enabled        :boolean          default(TRUE), not null
#  key            :string           not null
#  reference_type :string
#  value          :jsonb
#  value_type     :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
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

  validates :value_type, inclusion: { in: %w[array string reference] }

  validate :value_type_matches_value
  validate :valid_reference_type

  def self.get_value(key)
    find_by(key: key)&.value
  end

  private

  def value_type_matches_value
    return if value.nil?

    case value_type
    when 'array' then value.is_a?(Array)
    when 'string' then value.is_a?(String)
    when 'reference' then value.is_a?(Integer)
    end
  end

  def valid_reference_type
    return if reference_type.nil?

    errors.add(:reference_type, 'is not valid') unless reference_type.in?(%w[Topic Mention])
  end
end
