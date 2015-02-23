class CreatePrioritizedCountries < ActiveRecord::Migration
  def change
    create_table :prioritized_countries do |t|
      t.references :site, index: true, null: false
      t.references :country, index: true, null: false

      t.timestamps null: false
    end
    add_foreign_key :prioritized_countries, :sites
    add_foreign_key :prioritized_countries, :countries
  end
end
