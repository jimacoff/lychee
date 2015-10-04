class AddOrderToCategoryMember < ActiveRecord::Migration
  def change
    add_column :category_members, :order, :integer, null: false
  end
end
