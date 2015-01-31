class Category < ActiveRecord::Base
  has_paper_trail

  include Metadata
  include Slug
  include Taggable

  belongs_to :parent_category, class_name: 'Category'
  has_many :subcategories, class_name: 'Category',
                           foreign_key: 'parent_category_id'

  has_many :category_members
  has_many :products, through: :category_members
  has_many :variants, through: :category_members

  validates :name, :description, presence: true
end
