class AddEnabledToImage < ActiveRecord::Migration
  def change
    add_column :images, :enabled, :boolean, default: true, null: false
  end
end
