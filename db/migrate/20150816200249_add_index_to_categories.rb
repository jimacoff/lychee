class AddIndexToCategories < ActiveRecord::Migration
  def change
    add_index :categories, [:site_id, :name], unique: true
    add_index :categories, [:site_id, :generated_slug], unique: true
    add_index :categories, [:site_id, :specified_slug], unique: true
  end
end
