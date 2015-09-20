class VariationInstance < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :variation
  belongs_to :variant

  has_one :image_instance, as: :imageable
  has_one :image, through: :image_instance

  has_paper_trail
  valhammer
end
