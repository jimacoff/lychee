class Order < ActiveRecord::Base
  include ParentSite
  include Monies

  include Metadata
  include Taggable

  has_one :customer_address, class_name: 'Address',
                             foreign_key: 'order_customer_address_id'
  has_one :delivery_address, class_name: 'Address',
                             foreign_key: 'order_delivery_address_id'

  has_many :commodity_line_items

  monies [{ field: :total, calculated: true }]

  has_paper_trail
  valhammer

  before_validation :calculate_total

  validates :customer_address, :delivery_address, presence: true

  # TODO: Store environment details about order, country, IP, browser etc
  # as many details as possible for use with risk APIs

  after_initialize do
    write_attribute(:currency, Site.current.currency.iso_code)
    change_total(0)
  end

  def calculate_total
    return create_monentary_value(0) unless commodity_line_items.present?

    # TODO: Taxation and postage
    create_monentary_value(commodity_line_items.map(&:total).sum.cents)
  end
end
