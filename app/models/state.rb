class State < ActiveRecord::Base
  belongs_to :country

  has_paper_trail
  valhammer
end
