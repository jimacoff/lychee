class ShoppingBagOperation < ActiveRecord::Base
  include ParentSite
  include CommodityReference
  include Metadata

  belongs_to :shopping_bag

  valhammer
  validate :metadata_cannot_be_nil

  default_scope { order('id') }

  delegate :metadata_fields, to: :product

  def self.by_uuid(uuid)
    where(item_uuid: uuid)
  end

  def matches_commodity?(opts)
    product_id == opts[:product_id].try(:to_i) &&
      variant_id == opts[:variant_id].try(:to_i)
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
