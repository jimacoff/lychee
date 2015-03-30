class CategoryMember < ActiveRecord::Base
  include ParentSite
  include ItemReference

  belongs_to :category

  has_paper_trail

  valhammer
end
