class CreateVariants < ActiveRecord::Migration
  def change
    create_table :variants do |t|
      t.belongs_to :product, null: false

      t.text :description, null: true

      t.string :gtin
      t.string :sku

      t.monetize :price, amount: { null: true, default: nil },
                         currency: { null: true, default: nil }

      t.integer :grams

      t.json :specifications
      t.hstore :metadata, null: true

      t.timestamps
    end
  end
end
