class AddUniqueValueIndexToVariationInstances < ActiveRecord::Migration
  def change
    add_index :variation_instances, [:variant_id, :variation_id, :value],
                                    unique: true, name: 'variant_unique_value'
  end
end
