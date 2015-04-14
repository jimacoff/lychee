class State < ActiveRecord::Base
  include ParentCountry

  has_paper_trail
  valhammer
end
