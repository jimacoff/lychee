class Variant < ActiveRecord::Base
  include ParentSite

  include Specification
  include Metadata
  include Taggable
  include Pricing

  belongs_to :product
  has_many :variation_instances
  has_many :variations, through: :variation_instances
  has_many :traits, through: :variations
  has_many :category_members
  has_many :categories, through: :category_members
  has_one :inventory

  monetize :price_cents, as: 'varied_price', allow_nil: true

  has_paper_trail
  valhammer

  validates :inventory, presence: true, on: :update
  validates :variation_instances, presence: true, on: :update

  def price
    varied_price || product.price
  end

  def price=(value)
    change_price(value)
  end

  def currency_for_price
    return Money::Currency.new('USD') unless site
    site.currency
  end
  alias_method :currency_for_varied_price, :currency_for_price

  def varied_price=(_price)
    fail 'varied_price cannot be directly set use #price='
  end

  def price_cents=(_value)
    fail 'price_cents cannot be directly set, use #price'
  end

  def price_currency=(_value)
    fail 'Currency cannot be set, use Site.current#currency'
  end

  %i(specifications description gtin sku grams).each do |attr|
    define_method(attr) do
      read_attribute(attr) || product && product.read_attribute(attr)
    end
  end
end
