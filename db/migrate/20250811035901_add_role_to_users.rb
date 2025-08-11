class AddRoleToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :users, :role, :integer, default: 0, null: false
    add_index :users, :role, algorithm: :concurrently
  end
end
