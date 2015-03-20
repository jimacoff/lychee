class Order < ActiveRecord::Base
  include ParentSite
  include Metadata

  has_one :customer_address, class_name: 'Address',
                             foreign_key: 'customer_address_for_id'
  has_one :delivery_address, class_name: 'Address',
                             foreign_key: 'delivery_address_for_id'

  has_paper_trail
  valhammer

  validates :customer_address, :delivery_address, presence: true
end
