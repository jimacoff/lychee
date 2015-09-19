class Variation < ActiveRecord::Base
  include ParentSite
  include Metadata

  enum render_as: [:radio, :drop_down]

  belongs_to :product
  belongs_to :trait

  has_many :variation_instances
  has_many :variants, through: :variation_instances

  has_paper_trail
  valhammer

  validates :order, numericality: { greater_than_or_equal_to: 0 }
end
