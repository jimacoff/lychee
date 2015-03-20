class CreateVariations < ActiveRecord::Migration
  def change
    create_table :variations do |t|
      t.belongs_to :product, null: false
      t.belongs_to :trait, null: false

      t.integer :order, null: false,
                        only_integer: true,
                        greater_than_or_equal_to: 0
      t.hstore :metadata, null: true

      t.timestamps

      t.index [:product_id, :order], unique: true
    end
  end
end
