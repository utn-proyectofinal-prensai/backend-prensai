# frozen_string_literal: true

class CreateNews < ActiveRecord::Migration[8.0]
  def change
    create_table :news do |t|
      t.string :title, null: false
      t.string :publication_type, null: false
      t.date :date, null: false
      t.string :support, null: false
      t.string :media, null: false
      t.string :section
      t.string :author
      t.string :interviewee
      t.string :link
      t.integer :audience_size
      t.decimal :quotation, precision: 10, scale: 2, default: 0.0
      t.string :valuation
      t.string :political_factor
      t.string :management
      t.text :plain_text
      t.references :topic, foreign_key: true

      t.timestamps
    end

    add_index :news, :date
    add_index :news, :media
    add_index :news, :publication_type
    add_index :news, :valuation
  end
end
