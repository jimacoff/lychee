class ShippingRateRegion < ActiveRecord::Base
  include ParentSite
  include ParentCountry
  include ParentState
  include Monies
  include Hierarchy
  include Metadata

  scope :supports_location, lambda { |location|
    where('hierarchy @> ?', location)
      .order(hierarchy: :desc).limit(1)
  }

  belongs_to :shipping_rate

  monies [{ field: :price }]

  has_paper_trail
  valhammer

  def valid_state
  end
end
