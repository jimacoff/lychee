class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :price_cents, null: false
      t.string :status, null: false, limit: 255

      t.hstore :metadata, null: true

      t.belongs_to :site, null: false, index: true

      t.timestamps null: false
    end
  end
end
