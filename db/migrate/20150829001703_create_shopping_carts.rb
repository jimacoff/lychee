class CreateShoppingCarts < ActiveRecord::Migration
  def change
    create_table :shopping_carts do |t|
      t.references :site, index: true, null: false

      t.string :workflow_state, null: false

      t.timestamps null: false

      t.foreign_key :sites, on_delete: :cascade
    end
  end
end
