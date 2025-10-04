# frozen_string_literal: true

class AddMetricsToClippings < ActiveRecord::Migration[8.0]
  def change
    add_column :clippings, :metrics, :jsonb, null: false, default: default_metrics_structure
    add_index :clippings, :metrics, using: :gin
  end

  private

  def default_metrics_structure
    {
      generated_at: nil,
      date_range: {
        from: nil,
        to: nil
      },
      news_count: 0,
      valuation: {
        positive: { count: 0, percentage: 0.0 },
        neutral: { count: 0, percentage: 0.0 },
        negative: { count: 0, percentage: 0.0 },
        total: 0
      },
      media_stats: {
        total: 0,
        items: []
      },
      support_stats: {
        total: 0,
        items: []
      },
      audience: {
        total: nil,
        average: nil,
        max: nil
      },
      quotation: {
        total: nil,
        average: nil,
        max: nil
      },
      crisis: false
    }
  end
end
