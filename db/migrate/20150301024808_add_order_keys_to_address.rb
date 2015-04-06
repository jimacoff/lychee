class AddOrderKeysToAddress < ActiveRecord::Migration
  def change
    add_reference :addresses, :order_customer_address, index: true
    add_reference :addresses, :order_delivery_address, index: true
  end
end
