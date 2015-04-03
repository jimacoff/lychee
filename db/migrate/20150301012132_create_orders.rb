class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :total_cents, null: false
      t.string :currency, null: false, default: 'USD'

      t.string :status, null: false, limit: 255

      t.hstore :metadata, null: true
      t.text :tags, array: true, default:[]

      t.belongs_to :site, null: false, index: true

      t.timestamps null: false
    end
  end
end
