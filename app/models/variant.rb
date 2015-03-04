class Variant < ActiveRecord::Base
  include ParentSite

  include Specification
  include Metadata
  include Taggable

  belongs_to :product
  has_many :variation_instances
  has_many :variations, through: :variation_instances
  has_many :traits, through: :variations
  has_many :category_members
  has_many :categories, through: :category_members
  has_one :inventory

  monetize :price_cents, as: 'varied_price',
                         with_model_currency: :price_currency, allow_nil: true

  has_paper_trail
  valhammer

  validates :inventory, presence: true
  validates :variation_instances, presence: true, on: :update

  def price
    varied_price || product.price
  end

  def price=(p)
    self.varied_price = p
  end

  %i(specifications description gtin sku grams).each do |attr|
    define_method(attr) do
      read_attribute(attr) || product && product.read_attribute(attr)
    end
  end
end
