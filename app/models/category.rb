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

  def render
  end

  def path
    "#{site.preferences.reserved_paths['categories']}/#{slug}"
  end
end
