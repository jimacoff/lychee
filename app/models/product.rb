class Product < ActiveRecord::Base
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

  with_options presence: true do |p|
    p.validates :name, :description
    p.validates :price_cents, :price_currency
    p.validates :inventory  # TODO: This shouldn't be here if there are variants
  end
end
