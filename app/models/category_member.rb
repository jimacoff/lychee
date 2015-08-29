class CategoryMember < ActiveRecord::Base
  include ParentSite
  include CommodityReference

  belongs_to :category

  has_one :image_instance, as: :imageable
  has_one :image, through: :image_instance

  has_paper_trail
  valhammer
end
