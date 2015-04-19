class ShippingRate < ActiveRecord::Base
  include ParentSite
  include Monies
  include Metadata

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
end
