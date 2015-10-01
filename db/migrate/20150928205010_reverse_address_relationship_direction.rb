class ReverseAddressRelationshipDirection < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.belongs_to :customer_address, :delivery_address, null: true
    end

    change_table :sites do |t|
      t.belongs_to :subscriber_address, null: true
    end

    execute('update orders set customer_address_id = addresses.id ' \
            'from addresses ' \
            'where orders.id = addresses.order_customer_address_id')

    execute('update orders set delivery_address_id = addresses.id ' \
            'from addresses ' \
            'where orders.id = addresses.order_delivery_address_id')

    execute('update sites set subscriber_address_id = addresses.id ' \
            'from addresses ' \
            'where sites.id = addresses.site_subscriber_address_id')

    add_foreign_key :orders, :addresses,
                    column: :customer_address_id, on_delete: :restrict
    add_foreign_key :orders, :addresses,
                    column: :delivery_address_id, on_delete: :restrict
    add_foreign_key :sites, :addresses,
                    column: :subscriber_address_id, on_delete: :restrict

    change_table :addresses do |t|
      t.remove :order_customer_address_id, :order_delivery_address_id,
               :site_subscriber_address_id
    end
  end
end
