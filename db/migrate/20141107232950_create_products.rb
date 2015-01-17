class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description, null: false

      t.string :generated_slug, null: false
      t.string :specified_slug

      t.string :gtin
      t.string :sku

      t.monetize :price, null: false

      t.integer :grams

      t.boolean :active
      t.datetime :not_before
      t.datetime :not_after

      t.json :specifications
      t.hstore :metadata, null: true

      t.timestamps
    end
  end
end
