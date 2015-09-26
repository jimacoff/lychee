class AddNameAndDescriptionToImageInstant < ActiveRecord::Migration
  def change
    add_column :image_instances, :name, :string
    add_column :image_instances, :description, :string
  end
end
