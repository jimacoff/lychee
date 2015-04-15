class Inventory < ActiveRecord::Base
  include ParentSite
  include CommodityReference
  include Metadata

  with_options if: :tracked? do |inv|
    inv.validates :quantity, presence: true
  end

  has_paper_trail
  valhammer

  def tracked?
    tracked
  end

  def stock?
    quantity > 0
  end
end
