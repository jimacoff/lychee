class CreateVariationInstances < ActiveRecord::Migration
  def change
    create_table :variation_instances do |t|
      t.references :variation, null: false, index: true
      t.references :variant, null: false, index: true

      t.string :value, null: false

      t.hstore :metadata, null: true

      t.timestamps
    end
  end
end
