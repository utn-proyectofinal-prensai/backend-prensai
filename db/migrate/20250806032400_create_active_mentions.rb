class CreateActiveMentions < ActiveRecord::Migration[8.0]
  def change
    create_table :active_mentions do |t|
      t.string :name
      t.integer :position
      t.boolean :is_active

      t.timestamps
    end
  end
end
