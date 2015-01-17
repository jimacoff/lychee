class AddProductVariantRelationshipToInventory < ActiveRecord::Migration
  def change
    change_table :inventories do |t|
      t.belongs_to :product
      t.belongs_to :variant
    end
  end
end
