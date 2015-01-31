class CreateCategoryMembers < ActiveRecord::Migration
  def change
    create_table :category_members do |t|
      t.belongs_to :category
      t.belongs_to :product
      t.belongs_to :variant

      t.timestamps
    end
  end
end
