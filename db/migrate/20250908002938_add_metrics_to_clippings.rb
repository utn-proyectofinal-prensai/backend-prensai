# frozen_string_literal: true

class AddMetricsToClippings < ActiveRecord::Migration[8.0]
  def change
    add_column :clippings, :metrics, :jsonb, null: false, default: {}
    add_index :clippings, :metrics, using: :gin
  end
end
