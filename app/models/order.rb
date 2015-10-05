class Order < ActiveRecord::Base
  include ParentSite
  include Monies

  include Metadata
  include Taggable

  include OrderWorkflow
  include OrderCalculation

  belongs_to :customer_address, class_name: 'Address'
  belongs_to :delivery_address, class_name: 'Address'

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

  validates :customer_address, :delivery_address,
            presence: { unless: :can_omit_customer_details? }

  # TODO: Store environment details about order, country, IP, browser etc
  # as many details as possible for use with risk APIs

  def self.create_from_bag(bag, attrs)
    create!(attrs).tap do |o|
      o.create_line_items_from_bag(bag)
      o.submit!
    end
  end

  def create_line_items_from_bag(bag)
    bag.contents.values.each do |entry|
      attrs = entry.slice(:product, :variant, :quantity, :metadata)
      commodity_line_items.create!(attrs)
    end
  end
end
