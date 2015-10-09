class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :display_name, null: false
      t.string :email, null: true
      t.string :phone_number, null: true

      t.timestamps null: false
    end
  end
end
