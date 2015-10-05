class RemoveDescriptionFromProduct < ActiveRecord::Migration
  def change
    remove_column :products, :description
  end
end
