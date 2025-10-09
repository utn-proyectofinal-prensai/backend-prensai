# frozen_string_literal: true

class CreateClippingReports < ActiveRecord::Migration[8.0]
  def change
    create_table :clipping_reports do |t|
      t.references :clipping, null: false, foreign_key: true, index: { unique: true }
      t.text :content, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end
