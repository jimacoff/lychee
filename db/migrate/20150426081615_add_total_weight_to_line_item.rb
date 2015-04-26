class AddTotalWeightToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :total_weight, :integer,
               allow_nil: true, default: 0
  end
end
