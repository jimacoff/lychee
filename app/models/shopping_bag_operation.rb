class ShoppingBagOperation < ActiveRecord::Base
  include ParentSite
  include CommodityReference
  include Metadata

  belongs_to :shopping_bag

  valhammer
  validate :metadata_cannot_be_nil

  default_scope { order('id') }

  def self.by_uuid(uuid)
    where(item_uuid: uuid)
  end

  def self.by_commodity(opts)
    where(opts.slice(:variant_id, :product_id))
      .where(arel_table[:metadata].eq(opts[:metadata]))
  end

  def matches_commodity?(opts)
    product_id == opts[:product_id].try(:to_i) &&
      variant_id == opts[:variant_id].try(:to_i) &&
      metadata == opts[:metadata]
  end

  def item_attrs
    { product: product, variant: variant, item_uuid: item_uuid,
      quantity: quantity, metadata: metadata }.compact
  end

  private

  def metadata_cannot_be_nil
    errors.add(:metadata, 'cannot be nil') if metadata.nil?
  end
end
