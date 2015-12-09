module OrderTransientHelpers
  extend ActiveSupport::Concern

  # Assist users transition from Bag to Order
  # before Order calculations are possible

  def transient_subtotal
    commodity_line_items.map { |cli| cli.price * cli.quantity }.sum
  end

  def transient_subtotal_cents
    commodity_line_items.map { |cli| cli.price.cents * cli.quantity }.sum
  end

  def transient_weight
    commodity_line_items.map { |cli| cli.weight * cli.quantity }.sum
  end

  def transient_total
    if transient_shipping_rate_estimate?
      return transient_subtotal +
        transient_shipping_rate_estimate.shipping_rate_regions.first.price
    end

    transient_subtotal
  end

  def transient_shipping_rate_estimate?
    return false unless transient_subtotal > 0

    ShippingRate.where(use_as_bag_shipping: true, enabled: true)
      .satisfies_price(transient_subtotal_cents)
      .satisfies_weight(transient_weight)
      .count > 0
  end

  def transient_shipping_rate_estimate
    return unless transient_subtotal > 0

    ShippingRate.where(use_as_bag_shipping: true, enabled: true)
      .satisfies_price(transient_subtotal_cents)
      .satisfies_weight(transient_weight)
      .first
  end
end
