class Variant < ActiveRecord::Base
  include ParentSite

  include Specification
  include Metadata
  include Taggable
  include Monies
  include Enablement

  belongs_to :product
  delegate :tax_override, to: :product
  delegate :tax_override=, to: :product

  has_many :variation_instances
  has_many :variations, through: :variation_instances
  has_many :traits, through: :variations
  has_many :category_members
  has_many :categories, through: :category_members
  has_one :inventory

  monies [{ field: :varied_price, calculated: true, allow_nil: true }]

  has_paper_trail
  valhammer

  validates :inventory, presence: true, on: :update
  validates :variation_instances, presence: true, on: :update

  def price
    varied_price || product.price
  end

  def price=(value)
    change_varied_price(value)
  end

  %i(specifications description gtin sku weight).each do |attr|
    define_method(attr) do
      read_attribute(attr) || product && product.read_attribute(attr)
    end
  end
end
