class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :generated_slug, null: false
      t.string :specified_slug
      t.text :description, null: false

      t.string :gtin
      t.string :sku

      t.money :price, null: false

      t.integer :grams
      t.json :specifications

      t.boolean :active
      t.datetime :not_before
      t.datetime :not_after

      t.json :variations

      t.timestamps
    end
  end
end
