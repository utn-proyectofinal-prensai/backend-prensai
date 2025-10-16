class AddReviewerToClippingReports < ActiveRecord::Migration[8.0]
  def change
    add_reference :clipping_reports, :reviewer, null: true, foreign_key: { to_table: :users }
    add_reference :clipping_reports, :creator, null: true, foreign_key: { to_table: :users }
  end
end
