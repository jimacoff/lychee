class AddNameToVariationInstances < ActiveRecord::Migration
  def change
    add_column :variation_instances, :name, :string, null: false
  end
end
