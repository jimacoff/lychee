class Product < ActiveRecord::Base
  include ParentSite

  include Monies
  include Specification
  include Content
  include Markup
  include Routable

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

  def variant(opts)
    # Uses a left outer join against variation_instances that DON'T match what
    # we're looking for, and then ensures that no such variation_instances exist
    variants.joins(variant_selection_join(opts))
      .find_by(variation_instances: { id: nil })
  end

  def create_default_path
    create_path(parent: default_path_parent, segment: name.to_url)
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

  def default_path_parent
    return nil unless site_assets_product_path
    Path.find_or_create_by_path(site_assets_product_path)
  end

  def site_assets_product_path
    site.preferences.reserved_path('products')
  end
end
