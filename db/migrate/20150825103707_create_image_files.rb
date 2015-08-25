class CreateImageFiles < ActiveRecord::Migration
  def change
    create_table :image_files do |t|
      t.references :site, index: true, null: false
      t.references :image, index: true, null: false

      t.string :filename, null: false
      t.string :width, null: false
      t.string :height
      t.string :x_dimension
      t.boolean :default_image, null: false, default: false
      t.boolean :original_image, null: false, default: false

      t.hstore :metadata, null: true

      t.timestamps null: false
    end

    add_foreign_key :image_files, :sites, on_delete: :cascade
    add_foreign_key :image_files, :images, on_delete: :cascade
  end
end
