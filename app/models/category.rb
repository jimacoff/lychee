class Category < ActiveRecord::Base
  has_paper_trail class_name: 'Versioning::CategoryVersion'

  include Metadata
  include Slug
  include Taggable

  belongs_to :parent_category, class_name: 'Category'
  has_many :subcategories, class_name: 'Category',
                           foreign_key: 'parent_category_id'

  has_and_belongs_to_many :products
  has_and_belongs_to_many :variants

  validates :name, :description, presence: true
end
