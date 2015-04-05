class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.string :iso_alpha2, null: false
      t.string :iso_alpha3, null: false

      t.string :postal_address_template, null: false

      t.timestamps null: false
    end
  end
end
