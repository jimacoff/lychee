class CreateShoppingCartOperations < ActiveRecord::Migration
  def change
    create_table :shopping_cart_operations do |t|
      t.references :shopping_cart, index: true, null: false

      t.references :product, null: true
      t.references :variant, null: true

      t.uuid :item_uuid, null: false
      t.integer :quantity, null: false
      t.hstore :metadata, null: true

      t.foreign_key :shopping_carts, on_delete: :cascade
      t.foreign_key :products, on_delete: :restrict
      t.foreign_key :variants, on_delete: :restrict
    end
  end
end
