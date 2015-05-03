class CreateLineItemTaxes < ActiveRecord::Migration
  def change
    create_table :line_item_taxes do |t|
      t.references :site, index: true, null: false
      t.references :line_item, index: true, null: false
      t.references :tax_rate, index: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :line_item_taxes, :sites, on_delete: :cascade
    add_foreign_key :line_item_taxes, :line_items, on_delete: :cascade
    add_foreign_key :line_item_taxes, :tax_rates, on_delete: :restrict
  end
end
