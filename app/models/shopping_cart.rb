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

  has_many :shopping_cart_operations

  valhammer

  def apply(opts)
    (opts[:item_uuid] && apply_item_update(opts)) || apply_item_add(opts)
  end

  def contents
    shopping_cart_operations.includes(:product, :variant).reduce({}) do |a, e|
      item = { product: e.product, variant: e.variant, item_uuid: e.item_uuid,
               quantity: e.quantity, metadata: e.metadata }
      a.merge(e.item_uuid => item.compact)
    end
  end

  private

  def apply_item_add(opts)
    prev = shopping_cart_operations.by_commodity(opts).order('id desc').first

    overrides = { item_uuid: (prev.try(:item_uuid) || SecureRandom.uuid) }
    overrides[:quantity] = opts[:quantity] + prev.quantity if prev

    shopping_cart_operations.create!(opts.merge(overrides))
  end

  def apply_item_update(opts)
    prev = shopping_cart_operations.by_uuid(opts[:item_uuid])
           .order('id desc').first

    return nil unless prev.try(:matches_commodity?, opts)

    shopping_cart_operations.create!(opts)
  end
end
