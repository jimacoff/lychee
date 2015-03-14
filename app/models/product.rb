class Product < ActiveRecord::Base
  include ParentSite

  include Specification
  include Metadata
  include Slug
  include Taggable
  include Pricing

  has_many :variants
  has_many :variations
  has_many :traits, through: :variations
  has_many :category_members
  has_many :categories, through: :category_members
  has_one :inventory

  validate :inventory, :validate_inventory
  with_options presence: true do |p|
    p.validates :name, :description
    p.validates :price_cents
  end

  has_paper_trail
  monetize :price_cents

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

  def price=(value)
    change_price(value)
  end

  def price_cents=(_value)
    fail 'price_cents cannot be directly set, use #price'
  end

  def price_currency=(_value)
    fail 'Currency cannot be set, use Site.current#currency'
  end

  def currency_for_price
    site.currency
  end
end
