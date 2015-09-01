class MakeCategoryMemberDescriptionOptional < ActiveRecord::Migration
  def change
    change_column_null :category_members, :description, true
  end
end
