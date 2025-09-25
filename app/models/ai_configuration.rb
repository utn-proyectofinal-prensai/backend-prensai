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
  RANSACK_ATTRIBUTES = %w[id key display_name value_type reference_type enabled created_at updated_at].freeze

  validates :key, presence: true, uniqueness: true
  validates :display_name, :value_type, presence: true

  scope :enabled, -> { where(enabled: true) }
  scope :ordered, -> { order(:display_name) }

  VALUE_TYPES = %w[array string reference].freeze
  REFERENCE_TYPES = %w[Topic Mention].freeze

  validates :value_type, inclusion: { in: VALUE_TYPES }

  with_options if: :reference_value_type? do
    validates :reference_type, presence: true, inclusion: { in: REFERENCE_TYPES }
  end
  validates :reference_type, absence: true, unless: :reference_value_type?

  validate :value_type_matches_value

  def self.get_value(key)
    find_by(key: key)&.value
  end

  def options
    return unless value_type == 'reference' && reference_type.present?

    reference_type.safe_constantize.enabled(true).ordered.pluck(:id, :name).map do |id, name|
      { value: id, label: name }
    end
  end

  private

  def value_type_matches_value
    return if value.nil?

    errors.add(:value, 'is not valid') unless case value_type
                                              when 'array' then value.is_a?(Array)
                                              when 'string' then value.is_a?(String)
                                              when 'reference' then value.is_a?(Integer)
                                              end
  end

  def reference_value_type?
    value_type == 'reference'
  end
end
