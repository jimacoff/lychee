class RenameShoppingCartToShoppingBag < ActiveRecord::Migration
  def change
    rename_index :shopping_cart_operations,
                 'index_shopping_cart_operations_on_shopping_cart_id',
                 'index_shopping_bag_operations_on_shopping_bag_id'

    rename_index :shopping_cart_operations,
                 'index_shopping_cart_operations_on_site_id',
                 'index_shopping_bag_operations_on_site_id'

    rename_index :shopping_carts,
                 'index_shopping_carts_on_site_id',
                 'index_shopping_bags_on_site_id'

    rename_table :shopping_carts, :shopping_bags
    rename_column :shopping_cart_operations, :shopping_cart_id, :shopping_bag_id
    rename_table :shopping_cart_operations, :shopping_bag_operations
  end
end
