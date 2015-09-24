class VariationValue < ActiveRecord::Base
  include ParentSite

  belongs_to :variation

  has_paper_trail
  valhammer
end
