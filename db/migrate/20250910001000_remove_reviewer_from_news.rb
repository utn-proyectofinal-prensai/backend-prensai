# frozen_string_literal: true

class RemoveReviewerFromNews < ActiveRecord::Migration[8.0]
  def change
    remove_reference :news, :reviewer, foreign_key: { to_table: :users }
  end
end
