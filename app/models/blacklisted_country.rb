class BlacklistedCountry < ActiveRecord::Base
  has_paper_trail

  belongs_to :site
  belongs_to :country
end
