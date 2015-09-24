class MoveNameAndDescriptionFromVariationInstanceToVariationValue < ActiveRecord::Migration
  def change
    add_column :variation_values, :name, :string, null: false
    add_column :variation_values, :description, :string, null: false

    remove_column :variation_instances, :name
    remove_column :variation_instances, :description
    remove_column :variation_instances, :value

    remove_column :variation_values, :value

    remove_index :variation_values, [:site_id, :variation_id, :order]
  end
end
