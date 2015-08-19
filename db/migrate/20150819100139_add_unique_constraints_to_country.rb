class AddUniqueConstraintsToCountry < ActiveRecord::Migration
  def change
    add_index :countries, :name, unique: true
    add_index :countries, :iso_alpha2, unique: true
    add_index :countries, :iso_alpha3, unique: true
  end
end
