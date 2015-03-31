class OrderLine < ActiveRecord::Base
  include ParentSite
  include Metadata
  include Taggable
  include Pricing
  include ItemReference

  belongs_to :order
  belongs_to :product
  belongs_to :variant

  monetize :price_cents

  has_paper_trail
  valhammer

  def price=(value)
    change_price(value)
  end

  def price_cents=(_value)
    fail 'price_cents cannot be directly set, use #price'
  end

  def price_currency=(_value)
    fail 'Currency cannot be set, use Site.current#currency'
  end

  def currency_for_price
    return Money::Currency.new('USD') unless site
    site.currency
  end

  def total
    # TODO: Taxation concerns
    Money.new((price * quantity), currency_for_price)
  end
end
