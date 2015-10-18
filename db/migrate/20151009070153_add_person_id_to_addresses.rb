class AddPersonIdToAddresses < ActiveRecord::Migration
  def change
    change_table :addresses do |t|
      t.belongs_to :person, null: false, unique: true
    end

    add_foreign_key :addresses, :people, on_delete: :restrict
  end
end
