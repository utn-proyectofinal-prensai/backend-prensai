class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.string :color
      t.boolean :is_active
      t.json :tags

      t.timestamps
    end
  end
end
