class ShippingRate < ActiveRecord::Base
  include ParentSite
  include Monies
  include Metadata

  scope :supports_location, lambda { |location|
    joins(:shipping_rate_regions)
      .where('shipping_rate_regions.hierarchy @> ?', location).uniq
  }

  scope :satisfies_price, lambda { |subtotal_cents|
    fail 'must query in base monetary units' unless subtotal_cents.is_a? Integer

    where('min_price_cents IS NULL or min_price_cents <= :subtotal_cents',
          subtotal_cents: subtotal_cents)
      .where('max_price_cents IS NULL or max_price_cents >= :subtotal_cents',
             subtotal_cents: subtotal_cents)
  }

  scope :satisfies_weight, lambda { |weight|
    fail 'must query in base weight units' unless weight.is_a? Integer

    where('min_weight IS NULL or min_weight <= :weight',
          weight: weight)
      .where('max_weight IS NULL or max_weight >= :weight',
             weight: weight)
  }

  monies [{ field: :min_price, allow_nil: true },
          { field: :max_price, allow_nil: true }]

  has_many :shipping_rate_regions

  has_paper_trail
  valhammer

  def location?(location)
    shipping_rate_regions.supports_location(location).count > 0
  end

  def price(location)
    region = shipping_rate_regions.supports_location(location).first
    fail('region not supported') unless region

    region.price
  end
end
