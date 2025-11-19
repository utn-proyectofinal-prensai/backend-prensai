# frozen_string_literal: true

class IncreaseQuotationPrecisionInNews < ActiveRecord::Migration[8.0]
  def up
    change_column :news, :quotation, :decimal, precision: 15, scale: 2, default: 0.0
  end

  def down
    change_column :news, :quotation, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
