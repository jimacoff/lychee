class AddShoppingBagReferenceToOrder < ActiveRecord::Migration
  def change
    add_belongs_to :orders, :shopping_bag, null: false
    add_foreign_key :orders, :shopping_bags, column: :shopping_bag_id,
                                             on_delete: :restrict
  end
end
