class AddCreatorAndReviewerToNews < ActiveRecord::Migration[8.0]
  def change
    add_reference :news, :creator, foreign_key: { to_table: :users }
    add_reference :news, :reviewer, foreign_key: { to_table: :users }
  end
end
