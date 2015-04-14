class RenameOrderLinesToLineItems < ActiveRecord::Migration
  def change
    rename_table :order_lines, :line_items
  end
end
