class CreateTaxCategories < ActiveRecord::Migration
  def change
    create_table :tax_categories do |t|
      t.references :site, :site, null: false, index: true
      t.references :site, :site_primary_tax_category, null: false, index: true

      t.string :name, null: false

      t.hstore :metadata, null: true

      t.timestamps null: false
    end

    # Due to a bug we have to set both true above then correct
    change_column_null :tax_categories, :site_primary_tax_category_id, true

    add_foreign_key :tax_categories, :sites, on_delete: :cascade
    add_foreign_key :tax_categories, :sites,
                    column: 'site_primary_tax_category_id', on_delete: :cascade
  end
end
