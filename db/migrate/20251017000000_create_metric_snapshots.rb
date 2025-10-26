class CreateMetricSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :metric_snapshots do |t|
      t.string :context, null: false, default: 'global'
      t.jsonb :data, null: false, default: {}
      t.datetime :generated_at, null: false

      t.timestamps
    end

    add_index :metric_snapshots, %i[context generated_at]
  end
end
