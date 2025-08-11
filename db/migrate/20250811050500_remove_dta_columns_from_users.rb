# frozen_string_literal: true

class RemoveDtaColumnsFromUsers < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :users, :provider, :string if column_exists?(:users, :provider)
      remove_column :users, :uid, :string if column_exists?(:users, :uid)
      # tokens se conserva por ahora porque hay código de impersonación que lo usa
    end
  end
end

