class ChangeOrderAddressReferencesToPersonReferences < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.remove :customer_address_id
      t.belongs_to :customer, null: true

      t.remove :delivery_address_id
      t.belongs_to :recipient, null: true
    end

    add_foreign_key :orders, :people, column: 'customer_id'
    add_foreign_key :orders, :people, column: 'recipient_id'
  end
end
