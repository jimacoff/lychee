class CommodityLineItem < LineItem
  include CommodityReference

  validates :quantity, :weight, :total_weight,
            presence: true, numericality: { greater_than_or_equal_to: 0 }

  def product=(product)
    return unless product

    super(product)
    change_price(product.price.cents)
    self.weight = product.weight
  end

  def variant=(variant)
    return unless variant

    super(variant)
    change_price(variant.price.cents)
    self.weight = variant.weight
  end

  def calculate_weight
    self.total_weight = weight * quantity
  end

  private

  def overloaded_tax_rates
    return {} unless commodity.tax_override.present?
    tax_rates_hash(commodity.tax_override)
  end
end
