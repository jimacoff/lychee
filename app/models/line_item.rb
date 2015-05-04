class LineItem < ActiveRecord::Base
  include ParentSite
  include Monies
  include Metadata
  include Taggable

  belongs_to :order
  has_many :line_item_taxes
  has_many :tax_rates, through: :line_item_taxes

  monies [{ field: :price }, { field: :total, calculated: true },
          { field: :tax, calculated: true }]

  has_paper_trail
  valhammer

  def price=(value)
    change_price(value)
  end

  abstract_method :calculate_total
end
