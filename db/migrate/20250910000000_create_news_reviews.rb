# frozen_string_literal: true

class CreateNewsReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :news_reviews do |t|
      t.references :news, null: false, foreign_key: true
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.jsonb :changeset, null: false, default: {}
      t.jsonb :news_snapshot, null: false, default: {}
      t.text :notes
      t.datetime :reviewed_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end

    add_index :news_reviews, :reviewed_at
  end
end
