module GeographicHierarchyConversion
  extend ActiveSupport::Concern

  private

  def geographic_hierarchy_conversion
    [country.try(:iso_alpha2), state.try(:iso_code), postcode, locality]
      .take_while { |field| field }
      .reduce(nil) { |a, e| ltree_sanitize(e, a) }
  end

  def ltree_sanitize(identifier, hierarchy)
    return unless identifier

    label = identifier.gsub(/[^0-9A-Za-z]/, '').downcase
    hierarchy ? %(#{hierarchy}.#{label}) : label
  end
end
