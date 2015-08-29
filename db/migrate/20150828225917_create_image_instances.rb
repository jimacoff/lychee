class CreateImageInstances < ActiveRecord::Migration
  def change
    create_table :image_instances do |t|
      t.references :site, index: true, null: false
      t.references :image, index: true, null: false
      t.references :imageable, polymorphic: true, index: true, null: false

      t.hstore :metadata, null: true

      t.timestamps null: false
    end

    add_foreign_key :image_instances, :sites, on_delete: :cascade
    add_foreign_key :image_instances, :images, on_delete: :restrict
  end
end
