class Variant < ActiveRecord::Base
  include Specification

  belongs_to :product

  monetize :price_cents, as: 'varied_price',
                         with_model_currency: :price_currency, allow_nil: true

  validates :product, presence: true
  validates :traits, trait: true

  def price
    varied_price || product.price
  end

  def price=(p)
    self.varied_price = p
  end

  @overloaded_attributes = %i(description gtin sku)
  @overloaded_attributes.each do |n|
    define_method(n) do
      read_attribute(n) || product.send(n)
    end
  end

  def add_trait(id, value)
    traits[id] = value
    traits_will_change!
  end

  def add_traits(new_traits)
    traits.merge! new_traits
    traits_will_change!
  end

  def delete_trait(id)
    traits.delete id
    traits_will_change!
  end
end
