class RenameHierarchyToGeographicHierarchy < ActiveRecord::Migration
  def change
    rename_column :tax_rates, :hierarchy, :geographic_hierarchy
    rename_column :shipping_rate_regions, :hierarchy, :geographic_hierarchy
  end
end
