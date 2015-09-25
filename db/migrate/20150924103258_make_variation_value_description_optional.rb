class MakeVariationValueDescriptionOptional < ActiveRecord::Migration
  def change
    change_column :variation_values, :description, :string, null: true
  end
end
