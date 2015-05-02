module Hierarchy
  extend ActiveSupport::Concern

  include HierarchyConversion

  included do
    before_validation :determine_hierarchy
    validate :hierarchy_fields
  end

  private

  def hierarchy_fields
    if postcode && !state
      errors.add(:postcode, 'State must be provided when specifying postcode')
    end

    return if !locality || (state && postcode)
    errors
      .add(:locality,
           'State and postcode must be provided when specifying locality')
  end

  def determine_hierarchy
    self.hierarchy = hierarchy_conversion
  end
end
