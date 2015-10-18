class AddMetadataFieldDescriptionsToModels < ActiveRecord::Migration
  def change
    add_column :tax_categories, :metadata_fields, :json, null: true
    add_column :shipping_rate_regions, :metadata_fields, :json, null: true
    add_column :variants, :metadata_fields, :json, null: true
    add_column :variations, :metadata_fields, :json, null: true
    add_column :categories, :metadata_fields, :json, null: true
    add_column :products, :metadata_fields, :json, null: true
    add_column :line_items, :metadata_fields, :json, null: true
    add_column :addresses, :metadata_fields, :json, null: true
    add_column :images, :metadata_fields, :json, null: true
    add_column :image_files, :metadata_fields, :json, null: true
    add_column :image_instances, :metadata_fields, :json, null: true
    add_column :sites, :metadata_fields, :json, null: true
    add_column :variation_instances, :metadata_fields, :json, null: true
    add_column :orders, :metadata_fields, :json, null: true
    add_column :preferences, :metadata_fields, :json, null: true
    add_column :traits, :metadata_fields, :json, null: true
    add_column :inventories, :metadata_fields, :json, null: true
    add_column :tax_rates, :metadata_fields, :json, null: true
    add_column :shopping_bag_operations, :metadata_fields, :json, null: true
  end
end
