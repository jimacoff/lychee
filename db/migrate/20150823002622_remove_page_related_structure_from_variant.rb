class RemovePageRelatedStructureFromVariant < ActiveRecord::Migration
  def change
    remove_column :variants, :name
    remove_column :variants, :generated_slug
    remove_column :variants, :specified_slug
  end
end
