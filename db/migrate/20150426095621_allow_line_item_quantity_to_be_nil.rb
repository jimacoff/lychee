class AllowLineItemQuantityToBeNil < ActiveRecord::Migration
  def change
    change_column_null :line_items, :quantity, true
  end
end
