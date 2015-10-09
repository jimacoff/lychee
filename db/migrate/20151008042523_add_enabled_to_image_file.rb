class AddEnabledToImageFile < ActiveRecord::Migration
  def change
    add_column :image_files, :enabled, :boolean, default: true, null: false
  end
end
