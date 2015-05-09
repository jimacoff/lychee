class ShippingRateRegion < ActiveRecord::Base
  include ParentSite
  include ParentCountry
  include ParentState
  include Monies
  include GeographicHierarchy
  include Metadata
  include Enablement

  scope :supports_location, lambda { |location|
    where('geographic_hierarchy @> ?', location)
      .enabled
      .order(geographic_hierarchy: :desc).limit(1)
  }

  belongs_to :shipping_rate

  belongs_to :tax_override, class_name: 'TaxCategory',
                            foreign_key: 'tax_override_id'

  monies [{ field: :price }]

  has_paper_trail
  valhammer

  validates :geographic_hierarchy,
            uniqueness: { scope: [:site, :shipping_rate] }

  def valid_state
  end
end
