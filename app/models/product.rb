class Product < ActiveRecord::Base
  include Specification
  include Metadata
  include Variations

  has_many :variants

  monetize :price_cents, with_model_currency: :price_currency

  validates :name, :description, presence: true
  validates :slug, :generated_slug, presence: true
  validates :price_cents, :price_currency, presence: true

  acts_as_url :name, url_attribute: :generated_slug, sync_url: true

  def slug
    specified_slug || generated_slug
  end

  def slug=(specified_slug)
    self.specified_slug = specified_slug
  end
end
