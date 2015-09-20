class AddCreatedAtToShoppingCartOperations < ActiveRecord::Migration
  def change
    add_column :shopping_cart_operations, :created_at, :datetime, null: false
  end
end
