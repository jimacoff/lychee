class UpdateSegmentIndexForPath < ActiveRecord::Migration
  def change
    remove_index :paths, [:site_id, :segment]
    add_index :paths, [:site_id, :parent_id, :segment], unique: true,
                      where: 'parent_id IS NOT NULL'
    add_index :paths, [:site_id, :segment], unique: true,
                      where: 'parent_id IS NULL'
  end
end
