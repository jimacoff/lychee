class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name, null: false

      t.text :whitelisted_countries, array: true, default:[]
      t.text :blacklisted_countries, array: true, default:[]
      t.text :priority_countries, array: true, default:[]

      t.timestamps null: false
    end
  end
end
