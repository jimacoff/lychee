class AddTaxOverrideToShippingRateRegion < ActiveRecord::Migration
  def change
    add_reference :shipping_rate_regions, :tax_override, null: true, index: true

    add_foreign_key :shipping_rate_regions, :tax_categories,
                    column: 'tax_override_id', on_delete: :restrict
  end
end
