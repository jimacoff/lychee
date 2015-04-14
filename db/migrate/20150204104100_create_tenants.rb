class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.references :site, null: false, index: true

      t.string :identifier, null: false

      t.timestamps null: false
    end

    add_index :tenants, :identifier
    add_foreign_key :tenants, :sites, on_delete: :cascade
  end
end
