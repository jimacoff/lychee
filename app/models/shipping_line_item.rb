class ShippingLineItem < LineItem
  belongs_to :shipping_rate_region

  validates :shipping_rate_region, presence: true

  def shipping_rate_region=(shipping_rate_region)
    return unless shipping_rate_region

    super(shipping_rate_region)
    change_price(shipping_rate_region.price.cents)
  end

  def calculate_subtotal
    change_subtotal(price.cents)
  end

  def overloaded_tax_rates
    return {} unless shipping_rate_region.tax_override.present?
    tax_rates_hash(shipping_rate_region.tax_override)
  end
end
