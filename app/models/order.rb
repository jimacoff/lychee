class Order < ActiveRecord::Base
  include ParentSite
  include Metadata

  has_one :customer_address, class_name: 'Address',
                             foreign_key: 'customer_address_for_id'
  has_one :delivery_address, class_name: 'Address',
                             foreign_key: 'delivery_address_for_id'

  has_many :order_lines

  has_paper_trail
  valhammer

  validates :customer_address, :delivery_address, presence: true

  # TODO: Store environment details about order, country, IP, browser etc
  # as many details as possible for use with risk APIs
end
