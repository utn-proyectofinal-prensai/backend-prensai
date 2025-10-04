# frozen_string_literal: true

class CreateClippings < ActiveRecord::Migration[8.0]
  def change
    create_table :clippings do |t|
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.jsonb :news_ids, null: false, default: []
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :topic, null: false, foreign_key: true

      t.timestamps
    end

    add_index :clippings, :start_date
    add_index :clippings, :end_date
    add_index :clippings, :news_ids, using: :gin
  end
end
