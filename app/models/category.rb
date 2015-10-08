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
    create_path(parent: default_path_parent, segment: name.to_url)
  end

  private

  def default_path_parent
    return nil unless site_assets_category_path || parent_category.present?

    if parent_category.present? && parent_category.path.present?
      parent_category.path
    else
      Path.find_or_create_by_path(site_assets_category_path)
    end
  end

  def site_assets_category_path
    site.preferences.reserved_path('categories')
  end
end
