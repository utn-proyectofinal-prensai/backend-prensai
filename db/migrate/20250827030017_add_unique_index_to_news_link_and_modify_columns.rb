class AddUniqueIndexToNewsLinkAndModifyColumns < ActiveRecord::Migration[8.0]
  def change
    change_table :news, bulk: true do |t|
      t.remove :management, type: :string
      t.change_null :link, false
      t.change_null :publication_type, true
    end

    add_index :news, :link, unique: true
  end
end
