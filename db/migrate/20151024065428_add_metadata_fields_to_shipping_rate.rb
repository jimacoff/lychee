class AddMetadataFieldsToShippingRate < ActiveRecord::Migration
  def change
    add_column :shipping_rates, :metadata_fields, :json, null: true
  end
end
