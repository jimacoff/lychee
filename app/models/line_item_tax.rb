class LineItemTax < ActiveRecord::Base
  include ParentSite

  belongs_to :line_item
  belongs_to :tax_rate

  has_paper_trail
  valhammer
end
