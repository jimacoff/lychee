class WhitelistedCountry < ActiveRecord::Base
  belongs_to :site
  belongs_to :country

  has_paper_trail
  valhammer
end
