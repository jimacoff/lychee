class AddDescriptionToVariationInstances < ActiveRecord::Migration
  def change
    add_column :variation_instances, :description, :string, null: false
  end
end
