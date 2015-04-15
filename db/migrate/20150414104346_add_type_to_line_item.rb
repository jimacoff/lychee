class AddTypeToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :type, :string, null: false, index: true
  end
end
