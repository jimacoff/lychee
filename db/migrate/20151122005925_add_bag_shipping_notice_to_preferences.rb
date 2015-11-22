class AddBagShippingNoticeToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :bag_shipping_notice, :string
  end
end
