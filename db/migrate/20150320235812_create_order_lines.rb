class CreateOrderLines < ActiveRecord::Migration
  def change
    create_table :order_lines do |t|
      t.string :customisation

      t.integer :quantity, null: false

      t.integer :price_cents, null: false
      t.integer :total_cents, null: false, default: 0
      t.string :currency, null: false, default: 'USD'

      t.references :site, null: false, index: true
      t.references :order, null: false, index: true
      t.references :product, null: true, index: true
      t.references :variant, null: true, index: true

      t.hstore :metadata, null: true
      t.text :tags, array: true, default:[]

      t.timestamps null: false
    end
  end
end
