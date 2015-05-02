module GeographicHierarchy
  extend ActiveSupport::Concern

  include GeographicHierarchyConversion

  included do
    before_validation :determine_geographic_hierarchy
    validate :geographic_hierarchy_fields
  end

  private

  def geographic_hierarchy_fields
    if postcode && !state
      errors.add(:postcode, 'State must be provided when specifying postcode')
    end

    return if !locality || (state && postcode)
    errors
      .add(:locality,
           'State and postcode must be provided when specifying locality')
  end

  def determine_geographic_hierarchy
    self.geographic_hierarchy = geographic_hierarchy_conversion
  end
end
