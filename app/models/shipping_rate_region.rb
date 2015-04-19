class ShippingRateRegion < ActiveRecord::Base
  include ParentSite
  include ParentCountry
  include ParentState
  include Monies
  include Hierarchy
  include Metadata

  belongs_to :shipping_rate

  monies [{ field: :price }]

  has_paper_trail
  valhammer
end
