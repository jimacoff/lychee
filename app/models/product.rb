class Product < ActiveRecord::Base
  has_paper_trail class_name: 'ProductVersion'

  include Specification
  include Metadata
  include Slug
  include Taggable

  has_many :variants
  has_many :variations
  has_many :traits, through: :variations
  has_one :inventory
  has_and_belongs_to_many :categories

  monetize :price_cents, with_model_currency: :price_currency

  validate :inventory, :validate_inventory
  with_options presence: true do |p|
    p.validates :name, :description
    p.validates :price_cents, :price_currency
  end

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
end
