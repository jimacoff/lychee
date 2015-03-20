class Inventory < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :product
  belongs_to :variant

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
