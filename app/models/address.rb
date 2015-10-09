class Address < ActiveRecord::Base
  include ParentSite
  include ParentCountry
  include ParentState
  include Metadata
  include GeographicHierarchyConversion

  belongs_to :person

  has_paper_trail
  valhammer

  # Address Format:
  # line1 - 4: Addresse, building, street etc per local requirements
  # locality: locality, suburb, city, post town
  # state: state, province, region
  # postcode: postal code, zip code
  # country

  def to_s(force_country = false)
    requires_country = force_country || (country != site.country)
    country.format_postal_address(self, requires_country)
  end

  def state?
    state.present?
  end

  def to_geographic_hierarchy
    geographic_hierarchy_conversion
  end
end
