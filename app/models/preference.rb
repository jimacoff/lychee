class Preference < ActiveRecord::Base
  include ParentSite
  include Metadata

  enum tax_basis: { delivery: 0, customer: 1, subscriber: 2 }

  # TODO: prices_include_tax likey means order_subtotal_include_tax should
  # also be false, i.e. American orders - when create pref screen.

  has_paper_trail
  valhammer

  validate :subtotal_must_include_taxes_when_prices_tax_inclusive

  def subtotal_must_include_taxes_when_prices_tax_inclusive
    return unless prices_include_tax && !order_subtotal_include_tax

    errors.add(:order_subtotal_include_tax)
  end
end
