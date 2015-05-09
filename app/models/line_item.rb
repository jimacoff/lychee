class LineItem < ActiveRecord::Base
  include ParentSite
  include Monies
  include Metadata
  include Taggable

  belongs_to :order
  has_many :line_item_taxes
  has_many :tax_rates, through: :line_item_taxes

  monies [{ field: :price },
          { field: :subtotal, calculated: true },
          { field: :total, calculated: true },
          { field: :tax, calculated: true }]

  validates :total_tax_rate, numericality: { greater_than_or_equal_to: 0.0,
                                             less_than_or_equal_to: 1.0 }

  has_paper_trail
  valhammer

  def price=(value)
    change_price(value)
  end

  def calculate_total
    unless valid? && price.try(:present?) && order.try(:valid?)
      fail 'attempt to calculate total with invalid state'
    end

    calculate_subtotal
    calculate_tax_rate
    calculate_tax
    finalise_total
  end

  private

  def calculate_subtotal
    change_subtotal(price.cents * quantity)
  end

  def calculate_tax_rate
    ##
    # The ultimate set of tax rates across all priorities give
    # overloaded values at the same priority level precedence
    # throwing away those specified by default.
    #
    # In this way a default GST of 10% can be set to 0 for excluded items
    # (such as fruits and vegetables in Australia) which would specify a
    # TaxCategory to handle this case as tax_override.
    #
    # No overrides, anticpated to often be the case
    self.tax_rates = default_tax_rates.merge(overloaded_tax_rates).values
    self.total_tax_rate = tax_rates.sum(:rate)
  end

  def default_tax_rates
    tax_rates_hash(site.primary_tax_category)
  end

  def overloaded_tax_rates
    return {} unless commodity.tax_override.present?
    tax_rates_hash(commodity.tax_override)
  end

  def geo_hierarchy
    determine_taxable_address.to_geographic_hierarchy
  end

  def determine_taxable_address
    tax_bases = Preference.tax_bases
    case site.preferences[:tax_basis]
    when tax_bases[:delivery]
      return order.delivery_address
    when tax_bases[:customer]
      return order.customer_address
    when tax_bases[:subscriber]
      return site.subscriber_address
    end
  end

  def tax_rates_hash(tax_category)
    tax_rates = TaxRate.required_for_location(geo_hierarchy, tax_category)

    tax_rates.inject({}) do |hash, tax_rate|
      hash.merge(tax_rate.priority => tax_rate)
    end
  end

  def prices_include_tax?
    site.preferences.prices_include_tax
  end

  def tax_prices_inclusive
    (subtotal / (1 + total_tax_rate)).cents
  end

  def tax_prices_exclusive
    (subtotal * total_tax_rate).cents
  end

  def calculate_tax
    if prices_include_tax?
      change_tax(tax_prices_inclusive)
    else
      change_tax(tax_prices_exclusive)
    end
  end

  def finalise_total
    if prices_include_tax?
      change_total(subtotal.cents)
    else
      change_total(subtotal.cents + tax.cents)
    end
  end
end
