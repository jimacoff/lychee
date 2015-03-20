class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.references :parent_category, index: true

      t.string :name, null: false
      t.text :description, null: false

      t.string :generated_slug, null: false
      t.string :specified_slug

      t.hstore :metadata, null: true
      t.text :tags, array: true, default:[]

      t.timestamps null: false
    end
  end
end
