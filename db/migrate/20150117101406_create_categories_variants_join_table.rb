class CreateCategoriesVariantsJoinTable < ActiveRecord::Migration
  def change
    create_table :categories_variants, id: false do |t|
      t.integer :category_id
      t.integer :variant_id
    end

    add_index :categories_variants, [:category_id, :variant_id]
  end
end
