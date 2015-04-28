class OrderSubtotalCentsAndWeightNotNull < ActiveRecord::Migration
  def change
    change_column_null :orders, :subtotal_cents, false
    change_column_null :orders, :weight, false
  end
end
