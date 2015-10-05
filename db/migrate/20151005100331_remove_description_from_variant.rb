class RemoveDescriptionFromVariant < ActiveRecord::Migration
  def change
    remove_column :variants, :description
  end
end
