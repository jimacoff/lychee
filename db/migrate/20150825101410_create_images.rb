class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.references :site, index: true, null: false
      t.string :description, null: false

      t.hstore :metadata, null: true
      t.text :tags, array: true, default:[]

      t.timestamps null: false
    end

    add_foreign_key :images, :sites, on_delete: :cascade
  end

end
