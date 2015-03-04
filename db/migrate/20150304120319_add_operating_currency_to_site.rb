class AddOperatingCurrencyToSite < ActiveRecord::Migration
  change_table :sites do |t|
    t.string :operating_currency, default: 'USD', null: false
  end
end
