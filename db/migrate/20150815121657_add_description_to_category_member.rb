class AddDescriptionToCategoryMember < ActiveRecord::Migration
  def change
    add_column :category_members, :description, :string, null: false
  end
end
