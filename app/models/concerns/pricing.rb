module Pricing
  extend ActiveSupport::Concern

  private

  def change_price(value)
    fail 'Must be Numeric' unless value.is_a? Numeric

    if value.is_a?(Integer)
      money = Money.new(value, site.currency)
    else
      money = value.to_money(site.currency)
    end
    write_attribute(:price_cents, money.cents)
  end
end
