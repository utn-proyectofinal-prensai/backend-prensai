class AddIndexToNewsCreatedAt < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :news, :created_at, algorithm: :concurrently
  end
end
