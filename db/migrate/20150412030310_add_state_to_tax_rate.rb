class AddStateToTaxRate < ActiveRecord::Migration
  def change
    remove_column :tax_rates, :state
    add_reference :tax_rates, :state, null: true, index: true

    add_foreign_key :tax_rates, :states, on_delete: :restrict
  end
end
