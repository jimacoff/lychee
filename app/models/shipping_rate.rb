class ShippingRate < ActiveRecord::Base
  include ParentSite
  include Monies
  include Metadata
  include Enablement

  scope :supports_location, lambda { |geographic_hierarchy|
    joins(:shipping_rate_regions)
      .enabled
      .where('shipping_rate_regions.geographic_hierarchy @> ? AND
             shipping_rate_regions.enabled = true',
             geographic_hierarchy)
  }

  scope :satisfies_price, lambda { |subtotal_cents|
    fail 'must query in base monetary units' unless subtotal_cents.is_a? Integer

    where('(min_price_cents IS NULL OR min_price_cents <= :subtotal_cents) AND
           (max_price_cents IS NULL OR max_price_cents >= :subtotal_cents)',
          subtotal_cents: subtotal_cents)
      .enabled
  }

  scope :satisfies_weight, lambda { |weight|
    fail 'must query in base weight units' unless weight.is_a? Integer

    where('(min_weight IS NULL OR min_weight <= :weight) AND
           (max_weight IS NULL OR max_weight >= :weight)',
          weight: weight)
      .enabled
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
