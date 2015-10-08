class RemoveSlugsFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :generated_slug
    remove_column :categories, :specified_slug
  end
end
