class AddPricingIncludesTaxToSite < ActiveRecord::Migration
  def change
    add_column :sites, :prices_include_tax, :boolean, null: false
  end
end
