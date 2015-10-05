class AddMarkupAndMarkupFormatToProduct < ActiveRecord::Migration
  def change
    add_column :products, :markup, :text, null: false
    add_column :products, :markup_format, :integer, default: 0
  end
end
