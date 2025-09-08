class CreateAiConfigurations < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_configurations do |t|
      t.string :key, null: false
      t.jsonb :value
      t.string :value_type, null: false
      t.string :display_name, null: false
      t.text :description
      t.boolean :enabled, default: true, null: false
      t.string :reference_type

      t.timestamps
    end

    add_index :ai_configurations, :key, unique: true
    add_index :ai_configurations, :enabled
  end
end
