class AddInternalNameToImage < ActiveRecord::Migration
  def change
    add_column :images, :internal_name, :string, null: false
    add_index :images, [:site_id, :internal_name], unique: true
  end
end
