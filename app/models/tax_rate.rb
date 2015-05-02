class TaxRate < ActiveRecord::Base
  include ParentSite
  include ParentCountry
  include ParentState
  include Hierarchy
  include Metadata

  belongs_to :tax_category

  has_paper_trail
  valhammer

  validates :rate, numericality: { greater_than_or_equal_to: 0.0,
                                   less_than_or_equal_to: 1.0 }

  validates :geographic_hierarchy, uniqueness: { scope: [:site, :priority] }
end
