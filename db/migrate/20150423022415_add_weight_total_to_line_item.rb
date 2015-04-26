class AddWeightTotalToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :weight, :integer
  end
end
