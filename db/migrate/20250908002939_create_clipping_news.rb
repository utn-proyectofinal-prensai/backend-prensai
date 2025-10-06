# frozen_string_literal: true

class CreateClippingNews < ActiveRecord::Migration[8.0]
  def up
    create_table :clipping_news do |t|
      t.references :clipping, null: false, foreign_key: true
      t.references :news, null: false, foreign_key: true
      t.timestamps
    end

    add_index :clipping_news, [:clipping_id, :news_id], unique: true
    add_index :clipping_news, :news_id

    execute <<~SQL
      INSERT INTO clipping_news (clipping_id, news_id, created_at, updated_at)
      SELECT id, (jsonb_array_elements_text(news_ids))::bigint, NOW(), NOW()
      FROM clippings
      WHERE jsonb_array_length(news_ids) > 0;
    SQL

    remove_index :clippings, name: :index_clippings_on_news_ids
    remove_column :clippings, :news_ids
  end

  def down
    add_column :clippings, :news_ids, :jsonb, null: false, default: []
    add_index :clippings, :news_ids, using: :gin

    execute <<~SQL
      UPDATE clippings
      SET news_ids = COALESCE(
        (
          SELECT jsonb_agg(news_id ORDER BY news_id)
          FROM clipping_news
          WHERE clipping_id = clippings.id
        ),
        '[]'::jsonb
      );
    SQL

    drop_table :clipping_news
  end
end
