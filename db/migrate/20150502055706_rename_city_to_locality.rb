class RenameCityToLocality < ActiveRecord::Migration
  def change
    rename_column :tax_rates, :city, :locality
    rename_column :shipping_rate_regions, :city, :locality
  end
end
