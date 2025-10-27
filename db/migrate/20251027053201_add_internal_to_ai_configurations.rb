class AddInternalToAiConfigurations < ActiveRecord::Migration[8.0]
  def change
    add_column :ai_configurations, :internal, :boolean, null: false, default: false
    add_index :ai_configurations, :internal
  end
end
