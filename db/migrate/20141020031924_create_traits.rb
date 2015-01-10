class CreateTraits < ActiveRecord::Migration
  def change
    create_table :traits do |t|

      t.string :name, null: false
      t.string :display_name, null: true
      t.text :description, null: true

      t.hstore :metadata, null: true

      # PostgreSQL arrays work with Rails out of the box for column
      # types such as text and integer but then requires explicit type
      # casts to work with string columns
      t.text :default_values, array: true, default:[]
      t.text :tags, array: true, default:[]

      t.timestamps
    end
  end
end
