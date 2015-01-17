class Variant < ActiveRecord::Base
  include Specification
  include Metadata

  belongs_to :product
  has_many :variation_instances
  has_many :variations, through: :variation_instances
  has_many :traits, through: :variations

  monetize :price_cents, as: 'varied_price',
                         with_model_currency: :price_currency, allow_nil: true

  validates :product, presence: true
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
