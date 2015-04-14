class PrioritizedCountry < ActiveRecord::Base
  include ParentSite
  include ParentCountry

  has_paper_trail
  valhammer
end
