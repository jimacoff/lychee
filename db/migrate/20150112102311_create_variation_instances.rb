class CreateVariationInstances < ActiveRecord::Migration
  def change
    create_table :variation_instances do |t|
      t.belongs_to :variation, null: false
      t.belongs_to :variant, null: false

      t.string :value, null: false

      t.hstore :metadata, null: true

      t.timestamps
    end
  end
end
