class AddSutotalCentsToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :subtotal_cents, :integer, null: false, default: 0
  end
end
