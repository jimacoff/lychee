class Address < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :country
  belongs_to :customer_address_for, class_name: 'Order',
                                    foreign_key: 'customer_address_for_id'
  belongs_to :delivery_address_for, class_name: 'Order',
                                    foreign_key: 'delivery_address_for_id'

  has_paper_trail
  valhammer

  validate :associated_with_order, on: :update

  # Address Format:
  # line1 - 4: Addresse, building, street etc per local requirements
  # locality: locality, suburb, city, post town
  # state: state, province, region
  # postcode: postal code, zip code
  # country

  def to_s
    country.format_postal_address(self)
  end

  private

  def associated_with_order
    return if customer_address_for.present? || delivery_address_for.present?
    errors.add(:base, 'Addresses must be associated with an order')
  end
end
