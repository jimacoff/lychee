class CreateWhitelistedCountries < ActiveRecord::Migration
  def change
    create_table :whitelisted_countries do |t|
      t.references :site, index: true, null: false
      t.references :country, index: true, null: false

      t.timestamps null: false
    end
    add_foreign_key :whitelisted_countries, :sites
    add_foreign_key :whitelisted_countries, :countries
  end
end
