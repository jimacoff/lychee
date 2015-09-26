class MakeImageFileHeightRequired < ActiveRecord::Migration
  def change
    change_column :image_files, :height, :string, null: false
  end
end
