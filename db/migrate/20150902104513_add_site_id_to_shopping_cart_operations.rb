class AddSiteIdToShoppingCartOperations < ActiveRecord::Migration
  def change
    change_table :shopping_cart_operations do |t|
      t.integer :site_id, limit: 8, null: false
    end

    add_index :shopping_cart_operations, :site_id
    add_foreign_key :shopping_cart_operations, :sites
  end
end
