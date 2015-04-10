class AddTaxCategoryToProduct < ActiveRecord::Migration
  def change
    add_reference :products, :tax_override, null: true, index: true

    add_foreign_key :products, :tax_categories,
                    column: 'tax_override_id', on_delete: :cascade
  end
end
