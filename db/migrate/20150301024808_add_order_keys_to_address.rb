class AddOrderKeysToAddress < ActiveRecord::Migration
  def change
    add_reference :addresses, :customer_address_for, index: true
    add_reference :addresses, :delivery_address_for, index: true
  end
end
