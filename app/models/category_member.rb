class CategoryMember < ActiveRecord::Base
  include ParentSite

  belongs_to :category
  belongs_to :product

  has_one :image_instance, as: :imageable
  has_one :image, through: :image_instance

  has_paper_trail
  valhammer
end
