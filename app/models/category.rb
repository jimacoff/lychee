class Category < ActiveRecord::Base
  include ParentSite
  include Metadata
  include Slug
  include Taggable

  belongs_to :parent_category, class_name: 'Category'
  has_many :subcategories, class_name: 'Category',
                           foreign_key: 'parent_category_id'

  has_many :category_members
  has_many :products, through: :category_members
  has_many :variants, through: :category_members

  has_paper_trail
  valhammer

  scope :primary, -> { where(parent_category: nil) }
end
