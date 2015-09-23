class VariationValue < ActiveRecord::Base
  include ParentSite

  belongs_to :variation

  has_one :image_instance, as: :imageable
  has_one :image, through: :image_instance

  has_paper_trail
  valhammer
end
