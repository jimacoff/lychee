class AddVariationValueReferenceToVariationInstance < ActiveRecord::Migration
  def change
    add_reference :variation_instances,
                  :variation_value, null: false, index: true
    add_foreign_key :variation_instances,
                    :variation_values, on_delete: :restrict
  end
end
