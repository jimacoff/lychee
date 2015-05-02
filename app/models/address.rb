class Address < ActiveRecord::Base
  include ParentSite
  include ParentCountry
  include ParentState
  include Metadata
  include HierarchyConversion

  belongs_to :order_customer_address, class_name: 'Order',
                                      foreign_key: 'order_customer_address_id'
  belongs_to :order_delivery_address, class_name: 'Order',
                                      foreign_key: 'order_delivery_address_id'

  belongs_to :site_subscriber_address, class_name: 'Site',
                                       foreign_key: 'site_subscriber_address_id'

  has_paper_trail
  valhammer

  validate :belongs_to_order_or_site, on: :update

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
    hierarchy_conversion
  end

  private

  def belongs_to_order_or_site
    addresses = [:order_customer_address, :order_delivery_address,
                 :site_subscriber_address]
    address_instances = addresses.map { |address| send(address) }.compact
    return if address_instances.one?

    if address_instances.none?
      errors.add(:base, "Must belong to one of #{addresses.join(', ')}")
    else
      errors.add(:base, 'Cannot belong to more then one of' \
                             " #{addresses.join(', ')}")
    end
  end
end
