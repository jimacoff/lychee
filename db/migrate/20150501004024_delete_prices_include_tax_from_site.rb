class DeletePricesIncludeTaxFromSite < ActiveRecord::Migration
  def change
    remove_column :sites, :prices_include_tax
  end
end
