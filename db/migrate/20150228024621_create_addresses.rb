class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :line1, null: false
      t.string :line2
      t.string :line3
      t.string :line4
      t.string :locality
      t.string :state
      t.string :postcode

      t.hstore :metadata, null: true

      t.references :country, null: false, index: true
      t.references :site, null: false, index: true

      t.timestamps null: false
    end
  end
end
