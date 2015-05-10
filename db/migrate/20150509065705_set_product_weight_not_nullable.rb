class SetProductWeightNotNullable < ActiveRecord::Migration
  def change
    change_column :products, :weight, :integer, null: false, default: 0
  end
end
