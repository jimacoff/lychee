class CreateVariations < ActiveRecord::Migration
  def change
    create_table :variations do |t|
      t.belongs_to :product, null: false
      t.belongs_to :trait, null: false

      t.integer :order, null: false
      t.hstore :metadata, null: true

      t.timestamps
    end
  end
end
