class LineItem < ActiveRecord::Base
  include ParentSite
  include Monies
  include Metadata
  include Taggable

  belongs_to :order

  monies [{ field: :price }, { field: :total, calculated: true }]

  has_paper_trail
  valhammer

  after_initialize do
    change_total(0)
  end

  def price=(value)
    change_price(value)
    calculate_total
  end

  def quantity=(quantity)
    super(quantity)
    calculate_total
  end

  abstract_method :calculate_total
end
