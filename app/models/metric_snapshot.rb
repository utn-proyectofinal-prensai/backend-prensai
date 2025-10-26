# frozen_string_literal: true

# == Schema Information
#
# Table name: metric_snapshots
#
#  id           :bigint           not null, primary key
#  context      :string           default("global"), not null
#  data         :jsonb            not null
#  generated_at :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_metric_snapshots_on_context_and_generated_at  (context,generated_at)
#
class MetricSnapshot < ApplicationRecord
  GLOBAL_CONTEXT = 'global'

  scope :for_context, ->(context) { where(context: context) }
  scope :ordered_by_recency, -> { order(generated_at: :desc) }

  validates :context, presence: true
  validates :generated_at, presence: true
  validates :data, presence: true
end
