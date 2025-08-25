# frozen_string_literal: true

class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :enabled, default: true, null: false
      t.boolean :crisis, default: false, null: false

      t.timestamps
    end

    add_index :topics, :name, unique: true
  end
end
