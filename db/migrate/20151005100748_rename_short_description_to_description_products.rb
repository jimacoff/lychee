class RenameShortDescriptionToDescriptionProducts < ActiveRecord::Migration
  def change
    rename_column :products, :short_description, :description
  end
end
