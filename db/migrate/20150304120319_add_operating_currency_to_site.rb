class AddOperatingCurrencyToSite < ActiveRecord::Migration
  change_table :sites do |t|
    t.string :currency_iso_code, null: false
  end
end
