class Category < ActiveRecord::Base
  include Metadata
  include Slug

  belongs_to :parent_category, class_name: 'Category'
  has_many :subcategories, class_name: 'Category',
                           foreign_key: 'parent_category_id'

  has_and_belongs_to_many :products
  has_and_belongs_to_many :variants

  validates :name, :description, presence: true
end
