class LineItemTax < ActiveRecord::Base
  include ParentSite
  include Monies

  belongs_to :line_item
  belongs_to :tax_rate

  monies [{ field: :tax_amount, calculated: false }]

  validates :used_tax_rate, numericality: { greater_than_or_equal_to: 0.0,
                                            less_than_or_equal_to: 1.0 }

  has_paper_trail
  valhammer
end
