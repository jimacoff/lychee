class CreatePathHierarchies < ActiveRecord::Migration
  def change
    create_table :path_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false, limit: 8
      t.integer :descendant_id, null: false, limit: 8
      t.integer :generations, null: false, limit: 8
    end

    add_index :path_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "path_anc_desc_idx"

    add_index :path_hierarchies, [:descendant_id],
      name: "path_desc_idx"
  end
end
