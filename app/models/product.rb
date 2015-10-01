class Product < ActiveRecord::Base
  include ParentSite

  include Monies
  include Enablement
  include Specification
  include Content

  has_many :variants
  has_many :variations
  has_many :traits, through: :variations
  has_many :category_members
  has_many :categories, through: :category_members
  has_one :inventory

  has_many :image_instances, as: :imageable
  has_many :images, through: :image_instances

  monies [{ field: :price }]

  belongs_to :tax_override, class_name: 'TaxCategory',
                            foreign_key: 'tax_override_id'

  has_paper_trail
  valhammer

  validate :inventory, :validate_inventory

  def validate_inventory
    return if new_record?
    inventory_required
    inventory_not_required
  end

  def inventory_required
    return unless variants.empty? && inventory.nil?
    errors.add(:inventory,
               'must be provided if product does not define variants')
  end

  def inventory_not_required
    return unless inventory.present? && variants.present?
    errors.add(:inventory, 'must not be provided if product defines variants')
  end

  def path
    "#{site.preferences.reserved_paths['products']}/#{slug}"
  end

  def variant(opts)
    # Uses a left outer join against variation_instances that DON'T match what
    # we're looking for, and then ensures that no such variation_instances exist
    variants.joins(variant_selection_join(opts))
      .find_by(variation_instances: { id: nil })
  end

  private

  def variant_selection_join(opts)
    v = Variant.arel_table
    vi = VariationInstance.arel_table

    v.join(vi, Arel::Nodes::OuterJoin)
      .on(v[:id].eq(vi[:variant_id]).and(variant_selection_join_conds(opts)))
      .join_sources
  end

  def variant_selection_join_conds(opts)
    vi = VariationInstance.arel_table

    opts.reduce(vi[:variation_id].not_in(opts.keys)) do |conds, (id, value_id)|
      conds.or(vi[:variation_id].eq(id)
               .and(vi[:variation_value_id].not_eq(value_id)))
    end
  end
end
