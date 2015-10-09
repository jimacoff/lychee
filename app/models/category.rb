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

  def create_default_path
    create_path(parent: default_parent_path, segment: name.to_url)
  end

  def default_parent_path
    return nil unless site_categories_path || parent_category_path?
    return parent_category.path if parent_category_path?

    Path.find_or_create_by_path(site_categories_path)
  end

  private

  def site_categories_path
    site.preferences.reserved_path('categories')
  end

  def parent_category_path?
    parent_category.present? && parent_category.path.present?
  end
end
