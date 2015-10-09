class AddForeignKeysToPathHierarchy < ActiveRecord::Migration
  def change
    add_foreign_key :path_hierarchies, :paths, column: :ancestor_id,
                                               on_delete: :restrict

    add_foreign_key :path_hierarchies, :paths, column: :descendant_id,
                                               on_delete: :restrict
  end
end
