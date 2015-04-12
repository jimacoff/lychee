class Country < ActiveRecord::Base
  has_many :states

  has_paper_trail
  valhammer

  def format_postal_address(address, international = false)
    address_fields = address.slice(:line1, :line2, :line3, :line4,
                                   :locality, :state, :postcode).symbolize_keys

    # Postage regulations require country is not provided
    # if parcels are domestic in nature
    address_fields[:country] = international ? name : nil
    postal_address = postal_address_template % address_fields
    postal_address.split(/\n/).reject(&:blank?).join("\n").upcase
  end

  def states?
    states.present?
  end
end
