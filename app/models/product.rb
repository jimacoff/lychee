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

  def render
  end

  def path
    "#{site.preferences.reserved_paths['products']}/#{slug}"
  end
end
