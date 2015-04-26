class LineItem < ActiveRecord::Base
  include ParentSite
  include Monies
  include Metadata
  include Taggable

  belongs_to :order

  monies [{ field: :price }, { field: :total, calculated: true }]

  has_paper_trail
  valhammer

  def price=(value)
    change_price(value)
    calculate_total
  end

  abstract_method :calculate_total
end
