class ChangeOrdersColumnsToNotNullable < ActiveRecord::Migration
  def change
    change_column_null :orders, :metadata, false
    change_column_null :orders, :workflow_state, false
  end
end
