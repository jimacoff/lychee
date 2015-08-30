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

  def apply(opts)
    (opts[:item_uuid] && apply_item_update(opts)) || apply_item_add(opts)
  end

  def contents
  end

  private

  def apply_item_add(opts)
    # TODO: Fold
    shopping_cart_operations.create!(opts.merge(item_uuid: SecureRandom.uuid))
  end

  def apply_item_update(opts)
    prev = shopping_cart_operations.where(opts.slice(:item_uuid))
           .order('id desc').first

    return nil if prev.nil? ||
                  prev.product_id != opts[:product_id] ||
                  prev.variant_id != opts[:variant_id]

    shopping_cart_operations.create!(opts)
  end
end
