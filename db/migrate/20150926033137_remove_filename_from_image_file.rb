class RemoveFilenameFromImageFile < ActiveRecord::Migration
  def change
    remove_column :image_files, :filename
  end
end
