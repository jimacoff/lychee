class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.belongs_to :site, null: false
      t.string :identifier, null: false

      t.timestamps null: false
    end

    add_index :tenants, :identifier
  end
end
