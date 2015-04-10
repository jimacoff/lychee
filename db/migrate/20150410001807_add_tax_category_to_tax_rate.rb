class AddTaxCategoryToTaxRate < ActiveRecord::Migration
  def change
    add_reference :tax_rates, :tax_category, null: false, index: true
  end
end
