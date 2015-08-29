class ShoppingCart < ActiveRecord::Base
  include ParentSite
  include Workflow

  workflow do
    state :active do
      event :checkout, transitions_to: :checked_out
      event :abandon, transitions_to: :abandoned
      event :cancel, transitions_to: :cancelled
    end

    state :checked_out do
      event :abandon, transitions_to: :abandoned
      event :cancel, transitions_to: :cancelled
    end

    state :cancelled
    state :abandoned
  end

  belongs_to :product
  belongs_to :variant

  has_many :shopping_cart_operations

  valhammer
end
