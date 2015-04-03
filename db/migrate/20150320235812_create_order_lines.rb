class CreateOrderLines < ActiveRecord::Migration
  def change
    create_table :order_lines do |t|
      t.string :customisation

      t.integer :quantity, null: false

      t.integer :price_cents, null: false
      t.integer :total_cents, null: false, default: 0
      t.string :currency, null: false, default: 'USD'

      t.belongs_to :site, null: false, index: true
      t.belongs_to :order, null: false, index: true
      t.belongs_to :product, null: true
      t.belongs_to :variant, null: true

      t.hstore :metadata, null: true
      t.text :tags, array: true, default:[]

      t.timestamps null: false
    end
  end
end
