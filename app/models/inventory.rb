class Inventory < ActiveRecord::Base
  include ParentSite
  include CommodityReference
  include Metadata

  has_paper_trail
  valhammer

  validates :quantity, presence: { if: :tracked }

  def stock?
    quantity > 0
  end
end
