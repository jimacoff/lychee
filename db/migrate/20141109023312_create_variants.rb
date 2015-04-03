class CreateVariants < ActiveRecord::Migration
  def change
    create_table :variants do |t|
      t.belongs_to :product, null: false

      t.text :description, null: true

      t.string :gtin
      t.string :sku

      t.integer :varied_price_cents, null: true
      t.string :currency, null: false, default: 'USD'

      t.integer :grams

      t.json :specifications
      t.hstore :metadata, null: true
      t.text :tags, array: true, default:[]

      t.timestamps
    end
  end
end
