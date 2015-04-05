class Country < ActiveRecord::Base
  has_paper_trail
  valhammer

  def format_postal_address(address)
    address_fields = address.slice(:line1, :line2, :line3, :line4,
                                   :locality, :state, :postcode).symbolize_keys
    postal_address = postal_address_template % address_fields
    postal_address.split(/\n/).reject(&:blank?).join("\n").upcase
  end
end
