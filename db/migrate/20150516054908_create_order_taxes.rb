class CreateOrderTaxes < ActiveRecord::Migration
  def change
    create_table :order_taxes do |t|
      t.references :site, index: true, null: false

      t.references :order, index: true, null: false
      t.references :tax_rate, index: true, null: false
      t.integer :tax_amount_cents, null: false, default: 0
      t.string :currency, null: false, default: 'USD'
      t.decimal :used_tax_rate, null: false, default: 0

      t.timestamps null: false
    end

    add_foreign_key :order_taxes, :sites, on_delete: :cascade
    add_foreign_key :order_taxes, :orders, on_delete: :cascade
    add_foreign_key :order_taxes, :tax_rates, on_delete: :restrict
  end
end
