class Product < ActiveRecord::Base
  include Specification
  include Metadata

  has_many :variants
  has_many :variations
  has_many :traits, through: :variations
  has_one :inventory

  monetize :price_cents, with_model_currency: :price_currency

  with_options presence: true do |p|
    p.validates :name, :description
    p.validates :slug, :generated_slug
    p.validates :price_cents, :price_currency
    p.validates :inventory
  end

  acts_as_url :name, url_attribute: :generated_slug, sync_url: true

  def slug
    specified_slug || generated_slug
  end

  def slug=(specified_slug)
    self.specified_slug = specified_slug
  end
end
