class AddTaxToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :tax_cents, :integer, null: false, default: 0
  end
end
