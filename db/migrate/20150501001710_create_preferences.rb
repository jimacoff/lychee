class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.references :site, index: true, null: false

      t.integer :tax_basis, null: false, default: 0
      t.boolean :prices_include_tax, null: false, default: false

      t.hstore :metadata, null: true
      t.timestamps null: false
    end

    add_foreign_key :preferences, :sites, on_delete: :cascade
  end
end
