class ShoppingCartOperation < ActiveRecord::Base
  include CommodityReference

  belongs_to :shopping_cart

  valhammer

  def self.by_uuid(uuid)
    where(item_uuid: uuid)
  end

  def self.by_commodity(opts)
    where(opts.slice(:variant_id, :product_id))
      .where(arel_table[:metadata].eq(opts[:metadata]))
  end

  def matches_commodity?(opts)
    %i(product_id variant_id metadata).all? { |k| self[k] == opts[k] }
  end
end
