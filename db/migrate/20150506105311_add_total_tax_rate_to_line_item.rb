class AddTotalTaxRateToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :total_tax_rate, :decimal, null: false, precision: 6, scale: 5, default: 0.0
  end
end
