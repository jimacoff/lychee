module CommodityReference
  extend ActiveSupport::Concern

  included do
    belongs_to :product
    belongs_to :variant

    validate :validate_belongs_to_product_or_variant
  end

  def validate_belongs_to_product_or_variant
    items = [:product, :variant]
    item_instances = items.map { |item| send(item) }.compact
    return if item_instances.one?

    if item_instances.none?
      errors.add(:base, "Must belong to one of #{items.join(', ')}")
    else
      errors.add(:base, 'Cannot belong to more then one of' \
                             " #{items.join(', ')}")
    end
  end
end
