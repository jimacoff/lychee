class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.references :country, null: false, index: true

      t.string :name, null: false
      t.string :iso_code, null: false
      t.string :postal_format, null: false
      t.string :tax_code, null: false

      t.timestamps null: false
    end

    add_foreign_key :states, :countries, on_delete: :cascade
  end
end
