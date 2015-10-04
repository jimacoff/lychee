class AddOrderToImageInstance < ActiveRecord::Migration
  def change
    add_column :image_instances, :order, :integer, null: false
  end
end
