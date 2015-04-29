class AddMetadataToSite < ActiveRecord::Migration
  def change
    add_column :sites, :metadata, :hstore
  end
end
