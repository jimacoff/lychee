class AddUseAsBagShippingToShippingRate < ActiveRecord::Migration
  def change
    add_column :shipping_rates, :use_as_bag_shipping, :boolean, default: false
  end
end
