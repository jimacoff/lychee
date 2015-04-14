class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string  :item_type, :null => false
      t.bigint  :item_id,   :null => false
      t.string  :event,     :null => false
      t.string  :whodunnit
      t.text  :object
      t.bigint  :transaction_id

      t.timestamps
    end

    add_index :versions, [:item_type, :item_id, :transaction_id]
  end
end
