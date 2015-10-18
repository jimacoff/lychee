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
end
