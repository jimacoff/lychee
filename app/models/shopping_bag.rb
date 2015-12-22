class ShoppingBag < ActiveRecord::Base
  include ParentSite
  include Workflow

  workflow do
    state :active do
      event :finalize, transitions_to: :finalized
      event :abandon, transitions_to: :abandoned
      event :cancel, transitions_to: :cancelled
    end

    state :finalized
    state :cancelled
    state :abandoned
  end

  has_many :shopping_bag_operations
  has_many :orders

  valhammer

  def apply(opts)
    opts = opts.dup
    opts[:metadata] ||= {}

    (opts[:item_uuid] && apply_item_update(opts)) || apply_item_add(opts)
  end

  def contents
    shopping_bag_operations.includes(:product, :variant).reduce({}) do |a, e|
      next a.except(e.item_uuid) if e.quantity.zero?

      a.merge(e.item_uuid => e.item_attrs)
    end
  end

  def subtotal
    contents.values.reduce(0) do |a, e|
      price = e[:product] ? e[:product].price : e[:variant].price
      a + (price * e[:quantity])
    end
  end

  def weight
    contents.values.reduce(0) do |a, e|
      weight = e[:product] ? e[:product].weight : e[:variant].weight
      a + (weight * e[:quantity])
    end
  end

  def item_count
    contents.values.reduce(0) { |a, e| a + e[:quantity] }
  end

  def shipping_rate?
    return false unless subtotal > 0

    ShippingRate.where(use_as_bag_shipping: true, enabled: true)
      .satisfies_price(subtotal_cents)
      .satisfies_weight(weight)
      .count > 0
  end

  def shipping_rate
    return unless subtotal > 0

    ShippingRate.where(use_as_bag_shipping: true, enabled: true)
      .satisfies_price(subtotal_cents)
      .satisfies_weight(weight)
      .first
  end

  private

  def apply_item_add(opts)
    shopping_bag_operations.create!(opts.merge(item_uuid: SecureRandom.uuid))
  end

  def apply_item_update(opts)
    prev = shopping_bag_operations.by_uuid(opts[:item_uuid]).last

    return nil unless prev.try(:matches_commodity?, opts)
    return prev if prev && opts.all? { |k, v| prev[k].to_s == v.to_s }
    shopping_bag_operations.create!(opts)
  end

  def subtotal_cents
    contents.values.reduce(0) do |a, e|
      price = e[:product] ? e[:product].price.cents : e[:variant].price.cents
      a + (price * e[:quantity])
    end
  end
end
