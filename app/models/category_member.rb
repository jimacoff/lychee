class CategoryMember < ActiveRecord::Base
  has_paper_trail

  belongs_to :category
  belongs_to :product
  belongs_to :variant

  validates :category, presence: true
end
