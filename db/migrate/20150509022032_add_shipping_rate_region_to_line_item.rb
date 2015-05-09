class AddShippingRateRegionToLineItem < ActiveRecord::Migration
  def change
    add_reference :line_items, :shipping_rate_region, null: true, index: true

    add_foreign_key :line_items, :shipping_rate_regions, on_delete: :restrict
  end
end
