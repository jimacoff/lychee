class Inventory < ActiveRecord::Base
  include Metadata

  with_options if: :tracked? do |v|
    v.validates :quantity, presence: true
  end

  def tracked?
    tracked
  end

  def stock?
    quantity > 0
  end
end