class AddOrderSubtotalPreferenceToSitePreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :order_subtotal_include_tax,
                             :boolean, null: false, default: true
  end
end
