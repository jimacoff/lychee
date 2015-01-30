class CreateProductVersions < ActiveRecord::Migration
  def change
    create_table :product_versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
      t.integer  :transaction_id
    end
    add_index :product_versions, [:item_type, :item_id, :transaction_id],
              name: 'p_index_on_item_type_and_item_id_and_transaction_id'
  end
end
