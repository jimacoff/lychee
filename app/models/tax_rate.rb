class TaxRate < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :tax_category

  belongs_to :country
  belongs_to :state

  before_validation :determine_hierarchy

  has_paper_trail
  valhammer

  validates :rate, numericality: { greater_than_or_equal_to: 0.0,
                                   less_than_or_equal_to: 1.0 }
  validate :hierarchy_fields

  private

  def hierarchy_fields
    if postcode && !state
      errors.add(:postcode, 'State must be provided when specifying postcode')
    end

    return if !city || (state && postcode)
    errors
      .add(:city, 'State and postcode must be provided when specifying city')
  end

  def determine_hierarchy
    return unless country

    self.hierarchy = nil
    ltree_sanitize(country.iso_alpha2)

    return unless state
    ltree_sanitize(state.tax_code)

    return unless postcode
    ltree_sanitize(postcode)

    return unless city
    ltree_sanitize(city)
  end

  def ltree_sanitize(identifier)
    label = identifier.gsub(/[^0-9A-Za-z]/, '')
    self.hierarchy = hierarchy ? %(#{hierarchy}.#{label}) : label
  end
end
