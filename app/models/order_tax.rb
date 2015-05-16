class OrderTax < ActiveRecord::Base
  include ParentSite
  include Monies

  monies [{ field: :tax_amount, calculated: false }]

  belongs_to :order
  belongs_to :tax_rate

  validates :used_tax_rate, numericality: { greater_than_or_equal_to: 0.0,
                                            less_than_or_equal_to: 1.0 }

  has_paper_trail
  valhammer
end
