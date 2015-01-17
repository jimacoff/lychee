class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.references :parent_category, index: true

      t.string :name
      t.text :description

      t.string :generated_slug, null: false
      t.string :specified_slug

      t.hstore :metadata, null: true

      t.timestamps null: false
    end
  end
end
