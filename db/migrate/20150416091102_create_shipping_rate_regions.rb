class CreateShippingRateRegions < ActiveRecord::Migration
  def change
    create_table :shipping_rate_regions do |t|
      t.references :site, null: false, index: true

      t.references :country, index: true, null: false
      t.references :state, index: true
      t.string :postcode
      t.string :city

      t.references :shipping_rate, index: true, null: false

      t.integer :price_cents, null: false
      t.string :currency, null: false, default: 'USD'

      t.ltree :hierarchy, null: false

      t.hstore :metadata

      t.timestamps null: false
    end

    add_foreign_key :shipping_rate_regions, :sites
    add_foreign_key :shipping_rate_regions, :countries
    add_foreign_key :shipping_rate_regions, :states
    add_foreign_key :shipping_rate_regions, :shipping_rates
  end
end
