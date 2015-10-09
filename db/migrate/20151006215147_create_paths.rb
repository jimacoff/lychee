class CreatePaths < ActiveRecord::Migration
  def change
    create_table :paths do |t|
      t.references :site, index: true, null: false
      t.references :routable, polymorphic: true, index: true

      t.string :segment, null: false
      t.integer :parent_id

      t.timestamps null: false
    end

    add_foreign_key :paths, :sites, on_delete: :cascade
    add_index :paths, [:site_id, :segment], unique: true
  end
end
