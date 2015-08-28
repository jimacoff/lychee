class AddNameToImage < ActiveRecord::Migration
  def change
    add_column :images, :name, :string, null: false
  end
end
