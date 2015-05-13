class AddTaxAmountToLineItemTaxes < ActiveRecord::Migration
  def change
    add_column :line_item_taxes, :currency, :string, null: false, default: 'USD'
    add_column :line_item_taxes, :tax_amount_cents, :integer,
               null: false, default: 0
    add_column :line_item_taxes, :used_tax_rate, :decimal, null: false, precision: 6, scale: 5, default: 0.0
  end
end
