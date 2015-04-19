class CreateShippingRates < ActiveRecord::Migration
  def change
    create_table :shipping_rates do |t|
      t.references :site, null: false, index: true

      t.string :name, null: false
      t.string :description, null: false

      t.integer :min_weight, null: true
      t.integer :max_weight, null: true

      t.integer :min_price_cents, null: true
      t.integer :max_price_cents, null: true
      t.string :currency, null: false, default: 'USD'

      t.hstore :metadata

      t.timestamps null: false
    end

    add_foreign_key :shipping_rates, :sites
  end
end
