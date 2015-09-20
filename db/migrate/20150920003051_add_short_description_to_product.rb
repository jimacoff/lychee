class AddShortDescriptionToProduct < ActiveRecord::Migration
  def change
    add_column :products, :short_description, :string, null: false
  end
end
