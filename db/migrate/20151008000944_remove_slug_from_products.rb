class RemoveSlugFromProducts < ActiveRecord::Migration
  def change
    remove_column :products, :generated_slug
    remove_column :products, :specified_slug
  end
end
