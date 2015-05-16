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
  has_many :shipping_line_items

  has_many :order_taxes
  has_many :tax_rates, through: :order_taxes

  monies [{ field: :subtotal, calculated: true, allow_nil: true },
          { field: :total_commodities, calculated: true },
          { field: :total_shipping, calculated: true },
          { field: :total_tax, calculated: true },
          { field: :total, calculated: true }]

  has_paper_trail
  valhammer

  validates :customer_address, :delivery_address, presence: true

  # TODO: Store environment details about order, country, IP, browser etc
  # as many details as possible for use with risk APIs

  def calculate_weight
    change_weight(0) && return unless commodity_line_items.present?
    change_weight(commodity_line_items.map(&:total_weight).sum)
  end

  def calculate_subtotal
    change_subtotal(0) && return unless commodity_line_items.present?

    if site.preferences.order_subtotal_include_tax
      calculate_subtotal_tax_inclusive
    else
      calculate_subtotal_tax_exclusive
    end
  end

  def calculate_total
    unless commodity_line_items.present? && shipping_line_items.present?
      fail 'attempt to calculate total with invalid state'
    end

    calculate_total_commodities
    calculate_total_shipping
    calculate_total_tax

    change_total(total_commodities.cents + total_shipping.cents)
  end

  private

  def change_weight(weight)
    write_attribute(:weight, weight)
  end

  def calculate_subtotal_tax_inclusive
    change_subtotal(commodity_line_items.map(&:total).sum.cents)
  end

  def calculate_subtotal_tax_exclusive
    change_subtotal(commodity_line_items.map(&:subtotal).sum.cents)
  end

  def calculate_total_commodities
    change_total_commodities(commodity_line_items.map(&:total).sum.cents)
  end

  def calculate_total_shipping
    change_total_shipping(shipping_line_items.map(&:total).sum.cents)
  end

  def calculate_total_tax
    change_total_tax(shipping_line_items.map(&:tax).sum.cents +
                     commodity_line_items.map(&:tax).sum.cents)
  end
end
