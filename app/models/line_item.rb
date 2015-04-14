class LineItem < ActiveRecord::Base
  include ParentSite
  include ItemReference

  include Monies

  include Metadata
  include Taggable

  belongs_to :order, touch: true
  belongs_to :product
  belongs_to :variant

  monies [{ field: :price }, { field: :total, calculated: true }]

  has_paper_trail
  valhammer

  after_initialize do
    write_attribute(:currency, Site.current.currency.iso_code)
    change_total(0)
  end

  def price=(value)
    change_price(value)
    calculate_total
  end

  def quantity=(value)
    super(value)
    calculate_total
  end

  private

  def calculate_total
    change_total(0) && return unless price.present? && quantity.present?

    # TODO: Taxation
    change_total(price.cents * quantity)
  end
end
