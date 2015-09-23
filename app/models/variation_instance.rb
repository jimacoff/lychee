class VariationInstance < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :variation
  belongs_to :variant
  belongs_to :variation_value

  has_paper_trail
  valhammer
end
