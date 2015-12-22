module OrderCalculation
  extend ActiveSupport::Concern

  def perform_calculations
    unless commodity_line_items.present? && shipping_line_items.present?
      fail 'attempt to calculate total with invalid state'
    end

    calculate_total_commodities
    calculate_total_shipping
    calculate_total_weight
    calculate_subtotal
    calculate_tax_rates
    calculate_total_tax

    calculate_final_total
  end

  private

  def change_weight(weight)
    self[:weight] = weight
  end

  def calculate_total_commodities
    commodity_line_items.each(&:calculate_total)
    change_total_commodities(commodity_line_items.map(&:total).sum.cents)
  end

  def calculate_total_shipping
    shipping_line_items.each(&:calculate_total)
    change_total_shipping(shipping_line_items.map(&:total).sum.cents)
  end

  def calculate_total_weight
    commodity_line_items.each(&:calculate_total_weight)
    change_weight(commodity_line_items.map(&:total_weight).sum)
  end

  def calculate_subtotal
    if site.preferences.order_subtotal_include_tax
      calculate_subtotal_tax_inclusive
    else
      calculate_subtotal_tax_exclusive
    end
  end

  def calculate_subtotal_tax_inclusive
    change_subtotal(commodity_line_items.map(&:total).sum.cents)
  end

  def calculate_subtotal_tax_exclusive
    change_subtotal(commodity_line_items.map(&:subtotal).sum.cents)
  end

  def calculate_total_tax
    change_total_tax(shipping_line_items.map(&:tax).sum.cents +
                     commodity_line_items.map(&:tax).sum.cents)
  end

  def calculate_tax_rates
    order_taxes.destroy_all

    tax_rate_totals.each do |tax_rate_id, total|
      tax_rate = TaxRate.find(tax_rate_id)
      order_taxes.create(tax_rate: tax_rate,
                         used_tax_rate: tax_rate.rate,
                         tax_amount: total.cents)
    end
  end

  def tax_rate_totals
    all_tax_rates.inject({}) do |h, lit|
      h.merge(lit.tax_rate.id => lit.tax_amount) do |_key, current, additional|
        current + additional
      end
    end
  end

  def all_tax_rates
    commodity_line_item_taxes + shipping_line_item_taxes
  end

  def commodity_line_item_taxes
    commodity_line_items.flat_map(&:line_item_taxes)
  end

  def shipping_line_item_taxes
    shipping_line_items.flat_map(&:line_item_taxes)
  end

  def calculate_final_total
    change_total(total_commodities.cents + total_shipping.cents)
  end
end
