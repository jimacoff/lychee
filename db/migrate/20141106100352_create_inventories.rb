class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.boolean :tracked, null: false, default: false
      t.integer :quantity, default: 0
      t.boolean :back_orders, null: false, default: false
      t.datetime :replenish_eta
      t.datetime :exhausted_on

      t.hstore :metadata, null: true

      t.timestamps
    end
  end
end
