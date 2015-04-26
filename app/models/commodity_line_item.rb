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

  def quantity=(quantity)
    super(quantity)
    calculate_total
    calculate_weight
  end

  def weight=(weight)
    super(weight)
    calculate_weight
  end

  private

  def calculate_weight
    write_attribute(:total_weight, weight * quantity)
  end

  def calculate_total
    change_total(0) && return unless price.present?

    # TODO: Taxation
    change_total(price.cents * quantity)
  end
end
