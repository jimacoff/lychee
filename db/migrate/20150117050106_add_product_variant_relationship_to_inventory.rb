class AddProductVariantRelationshipToInventory < ActiveRecord::Migration
  def change
    change_table :inventories do |t|
      t.references :product, null: true, index: true
      t.references :variant, null: true, index: true
    end
  end
end
