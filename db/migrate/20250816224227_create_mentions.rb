# frozen_string_literal: true

class CreateMentions < ActiveRecord::Migration[8.0]
  def change
    create_table :mentions do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :mentions, :name, unique: true
  end
end
