class CommodityLineItem < LineItem
  include CommodityReference

  private

  def calculate_total
    change_total(0) && return unless price.present? && quantity.present?

    # TODO: Taxation
    change_total(price.cents * quantity)
  end
end
