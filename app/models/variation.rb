class Variation < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :product
  belongs_to :trait

  has_many :variation_instances
  has_many :variants, through: :variation_instances

  has_paper_trail
  valhammer

  validates_numericality_of :order, greater_than_or_equal_to: 0
end
