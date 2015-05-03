class CategoryMember < ActiveRecord::Base
  include ParentSite
  include CommodityReference

  belongs_to :category

  has_paper_trail
  valhammer
end
