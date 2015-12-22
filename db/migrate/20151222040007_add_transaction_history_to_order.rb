class AddTransactionHistoryToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :transaction_history, :text, array:true, default: []
  end
end
