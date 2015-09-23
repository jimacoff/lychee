class CreateVariationValues < ActiveRecord::Migration
  def change
    create_table :variation_values do |t|
      t.references :site, index: true, null: false
      t.references :variation, index: true, null: false

      t.string :value, null: false
      t.integer :order, null: false

      t.timestamps null: false

      t.foreign_key :sites, on_delete: :cascade
      t.foreign_key :variations, on_delete: :cascade

      t.index [:site_id, :variation_id, :order], unique: true
    end
  end
end
