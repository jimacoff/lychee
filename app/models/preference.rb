class Preference < ActiveRecord::Base
  include ParentSite
  include Metadata

  enum tax_basis: { delivery: 0, customer: 1, subscriber: 2 }

  has_paper_trail
  valhammer
end
