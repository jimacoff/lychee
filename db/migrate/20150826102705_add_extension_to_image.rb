class AddExtensionToImage < ActiveRecord::Migration
  def change
    add_column :images, :extension, :string, null: false
  end
end
