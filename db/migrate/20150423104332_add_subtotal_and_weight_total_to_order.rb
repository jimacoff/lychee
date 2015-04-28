class AddSubtotalAndWeightTotalToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :subtotal_cents, :integer
    add_column :orders, :weight, :integer
  end
end
