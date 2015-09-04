class AddSiteIdToShoppingCartOperations < ActiveRecord::Migration
  def change
    change_table :shopping_cart_operations do |t|
      t.references :site, null: false, index: true
    end

    add_foreign_key :shopping_cart_operations, :sites, on_delete: :cascade
  end
end
