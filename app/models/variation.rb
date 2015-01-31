class Variation < ActiveRecord::Base
  has_paper_trail

  include Metadata

  belongs_to :product
  belongs_to :trait

  has_many :variation_instances
  has_many :variants, through: :variation_instances

  validates :product, :trait, presence: true
  validates :order, presence: true, uniqueness: { scope: :product }
  validates_numericality_of :order, only_integer: true,
                                    greater_than_or_equal_to: 0
end
