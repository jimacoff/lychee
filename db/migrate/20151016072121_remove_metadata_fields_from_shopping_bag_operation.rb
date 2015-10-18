class RemoveMetadataFieldsFromShoppingBagOperation < ActiveRecord::Migration
  def change
    remove_column :shopping_bag_operations, :metadata_fields
  end
end
