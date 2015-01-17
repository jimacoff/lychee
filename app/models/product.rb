class Product < ActiveRecord::Base
  include Specification
  include Metadata
  include Slug

  has_many :variants
  has_many :variations
  has_many :traits, through: :variations
  has_one :inventory

  monetize :price_cents, with_model_currency: :price_currency

  with_options presence: true do |p|
    p.validates :name, :description
    p.validates :price_cents, :price_currency
    p.validates :inventory
  end
end
