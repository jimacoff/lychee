class Category < ActiveRecord::Base
  include ParentSite
  include Enablement
  include Content

  belongs_to :parent_category, class_name: 'Category'
  has_many :subcategories, class_name: 'Category',
                           foreign_key: 'parent_category_id'

  has_many :category_members
  has_many :products, through: :category_members

  has_paper_trail
  valhammer

  scope :primary, -> { where(parent_category: nil) }
  scope :enabled, -> { where(enabled: true) }
end
