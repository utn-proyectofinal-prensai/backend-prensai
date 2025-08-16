class CreateMentionNews < ActiveRecord::Migration[8.0]
  def change
    create_table :mention_news do |t|
      t.references :mention, null: false, foreign_key: true
      t.references :new, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :mention_news, [:mention_id, :new_id], unique: true
  end
end
