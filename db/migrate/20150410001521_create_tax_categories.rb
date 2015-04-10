class CreateTaxCategories < ActiveRecord::Migration
  def change
    create_table :tax_categories do |t|
      t.belongs_to :site, null: false, index: true
      t.belongs_to :site, :site_primary_tax_category, null: true, index: true

      t.string :name, null: false

      t.hstore :metadata, null: true

      t.timestamps null: false
    end

    add_foreign_key :tax_categories, :sites, on_delete: :cascade
    add_foreign_key :tax_categories, :sites,
                    column: 'site_primary_tax_category_id', on_delete: :cascade
  end
end
