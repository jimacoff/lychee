module GeographicHierarchyConversion
  extend ActiveSupport::Concern

  private

  def geographic_hierarchy_conversion
    hierarchy = nil
    hierarchy = ltree_sanitize(country.try(:iso_alpha2), hierarchy)

    return hierarchy unless state
    hierarchy = ltree_sanitize(state.iso_code, hierarchy)

    return hierarchy unless postcode
    hierarchy = ltree_sanitize(postcode, hierarchy)

    return hierarchy unless locality
    hierarchy = ltree_sanitize(locality, hierarchy)

    hierarchy
  end

  def ltree_sanitize(identifier, hierarchy)
    return unless identifier

    label = identifier.gsub(/[^0-9A-Za-z]/, '').downcase
    hierarchy ? %(#{hierarchy}.#{label}) : label
  end
end
