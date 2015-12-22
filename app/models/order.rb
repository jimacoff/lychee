class Order < ActiveRecord::Base
  include ParentSite
  include Monies

  include Metadata
  include Taggable

  include OrderWorkflow
  include OrderCalculation
  include OrderTransientHelpers

  belongs_to :shopping_bag

  belongs_to :customer, class_name: 'Person'
  belongs_to :recipient, class_name: 'Person'

  has_one :customer_address, through: :customer, source: :address
  has_one :delivery_address, through: :recipient, source: :address

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

  validates :customer, :recipient,
            presence: { unless: :can_omit_customer_details? }
  validate :people_must_have_addresses

  def self.create_from_bag(bag, attrs)
    create!(attrs.merge(shopping_bag: bag)).tap do |o|
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

  def people_must_have_addresses
    person_must_have_address(:customer, customer)
    person_must_have_address(:recipient, recipient)
  end

  def use_billing_details_for_shipping
    customer_id == recipient_id
  end

  alias_method :use_billing_details_for_shipping?,
               :use_billing_details_for_shipping

  private

  def person_must_have_address(sym, person)
    return if person.nil? || person.address
    errors.add(sym, 'must have an address')
  end
end
