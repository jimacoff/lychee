class RemoveVariantFromCategoryMember < ActiveRecord::Migration
  def change
    remove_reference :category_members, :variant, index: true,
                                                  foreign_key: true
  end
end
