class AddStateToAddress < ActiveRecord::Migration
  def change
    remove_column :addresses, :state
    add_reference :addresses, :state, null: true, index: true

    add_foreign_key :addresses, :states, on_delete: :restrict
  end
end
