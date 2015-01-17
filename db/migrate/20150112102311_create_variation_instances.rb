class CreateVariationInstances < ActiveRecord::Migration
  def change
    create_table :variation_instances do |t|
      t.belongs_to :variation
      t.belongs_to :variant

      t.string :value

      t.hstore :metadata, null: true

      t.timestamps
    end
  end
end
