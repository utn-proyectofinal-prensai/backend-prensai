# frozen_string_literal: true

class CreateClippings < ActiveRecord::Migration[8.0]
  def change
    create_table :clippings do |t|
      t.string :name, null: false
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.jsonb :filters, null: false, default: {}
      t.jsonb :news_ids, null: false, default: [], array: true
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :clippings, :period_start
    add_index :clippings, :period_end
  end
end
