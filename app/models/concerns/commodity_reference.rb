module CommodityReference
  extend ActiveSupport::Concern

  included do
    belongs_to :product
    belongs_to :variant

    validate :validate_belongs_to_product_or_variant
  end

  def validate_belongs_to_product_or_variant
    items = [product, variant].compact
    return if items.one?

    if items.none?
      errors.add(:base, 'Must belong to a product or variant')
    else
      errors.add(:base, 'Cannot belong to a product and a variant')
    end
  end

  def commodity
    return product if product
    variant
  end
end
