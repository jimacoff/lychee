class CreateTaxRates < ActiveRecord::Migration
  def change
    create_table :tax_rates do |t|
      t.decimal :rate, null: false, precision: 6, scale: 5

      t.string :name, null: false
      t.string :description, null: false
      t.string :invoice_note

      t.references :site, null: false, index: true

      t.references :country, null: false, index: true
      t.string :state
      t.string :postcode
      t.string :city

      t.boolean :shipping

      t.integer :priority, null: false

      t.ltree :hierarchy, null: false

      t.hstore :metadata, null: true
      t.timestamps null: false
    end
  end
end
