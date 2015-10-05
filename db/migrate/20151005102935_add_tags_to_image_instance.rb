class AddTagsToImageInstance < ActiveRecord::Migration
  def change
    add_column :image_instances, :tags, :text, array: true, default:[]
  end
end
