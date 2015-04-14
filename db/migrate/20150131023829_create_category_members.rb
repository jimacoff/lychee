class CreateCategoryMembers < ActiveRecord::Migration
  def change
    create_table :category_members do |t|
      t.references :category, null: false

      t.references :product, null: true, index: true
      t.references :variant, null: true, index: true

      t.timestamps
    end
  end
end
