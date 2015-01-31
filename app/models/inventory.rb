class Inventory < ActiveRecord::Base
  has_paper_trail

  include Metadata

  belongs_to :product
  belongs_to :variant

  with_options if: :tracked? do |inv|
    inv.validates :quantity, presence: true
  end

  def tracked?
    tracked
  end

  def stock?
    quantity > 0
  end
end
