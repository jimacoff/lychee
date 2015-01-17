class CreateTraits < ActiveRecord::Migration
  def change
    create_table :traits do |t|

      t.string :name, null: false
      t.string :display_name, null: true
      t.text :description, null: true

      t.hstore :metadata, null: true

      t.text :default_values, array: true, default:[]
      t.text :tags, array: true, default:[]

      t.timestamps
    end
  end
end
