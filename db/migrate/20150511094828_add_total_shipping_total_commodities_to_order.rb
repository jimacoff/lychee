class AddTotalShippingTotalCommoditiesToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :total_commodities_cents,
               :integer, null: false, default: 0
    add_column :orders, :total_shipping_cents,
               :integer, null: false, default: 0
    add_column :orders, :total_tax_cents,
               :integer, null: false, default: 0
  end
end
