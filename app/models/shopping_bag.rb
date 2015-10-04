class ShoppingBag < ActiveRecord::Base
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

  has_many :shopping_bag_operations

  valhammer

  def apply(opts)
    (opts[:item_uuid] && apply_item_update(opts)) || apply_item_add(opts)
  end

  def contents
    shopping_bag_operations.includes(:product, :variant).reduce({}) do |a, e|
      next a.except(e.item_uuid) if e.quantity.zero?

      a.merge(e.item_uuid => e.item_attrs)
    end
  end

  def place_order(attrs)
    Order.create!(attrs).tap do |o|
      create_order_line_items(o)
      o.submit!
    end
  end

  private

  def apply_item_add(opts)
    prev = shopping_bag_operations.by_commodity(opts).last

    overrides = { item_uuid: (prev.try(:item_uuid) || SecureRandom.uuid) }
    overrides[:quantity] = Integer(opts[:quantity]) + prev.quantity if prev

    apply_operation(prev, opts.merge(overrides))
  end

  def apply_item_update(opts)
    prev = shopping_bag_operations.by_uuid(opts[:item_uuid]).last

    return nil unless prev.try(:matches_commodity?, opts)

    apply_operation(prev, opts)
  end

  def apply_operation(prev, attrs)
    return prev if prev && attrs.all? { |k, v| prev[k].to_s == v.to_s }
    shopping_bag_operations.create!(attrs)
  end

  def create_order_line_items(order)
    contents.values.each do |entry|
      attrs = entry.slice(:product, :variant, :quantity, :metadata)
      order.commodity_line_items.create!(attrs)
    end
  end
end
