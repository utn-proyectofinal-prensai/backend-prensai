# frozen_string_literal: true

class CreateClippingNews < ActiveRecord::Migration[8.0]
  def change
    create_table :clipping_news do |t|
      t.references :clipping, null: false, foreign_key: true
      t.references :news, null: false, foreign_key: true
      t.timestamps
    end

    add_index :clipping_news, %i[clipping_id news_id], unique: true
    remove_column :clippings, :news_ids, :jsonb, null: false, default: []
  end
end
