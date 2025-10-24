# frozen_string_literal: true

class AddEditorAndReviewerToClippings < ActiveRecord::Migration[7.1]
  def change
    add_reference :clippings, :reviewer, foreign_key: { to_table: :users }
  end
end
