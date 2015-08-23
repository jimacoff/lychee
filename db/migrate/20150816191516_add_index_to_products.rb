class AddIndexToProducts < ActiveRecord::Migration
  def change
    add_index :products, [:site_id, :name], unique: true
    add_index :products, [:site_id, :generated_slug], unique: true
    add_index :products, [:site_id, :specified_slug], unique: true
  end
end
