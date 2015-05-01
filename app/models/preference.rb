class Preference < ActiveRecord::Base
  include ParentSite
  include Metadata

  enum tax_basis: { shipping: 0, billing: 1, seller: 2 }

  has_paper_trail
  valhammer
end
