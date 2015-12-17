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
    unless valid? && order.try(:valid?)
      fail 'attempt to calculate total with invalid state'
    end

    calculate_subtotal
    calculate_taxes
    finalise_total
  end

  def calculate_total!
    calculate_total
    save!
  end

  private

  def calculate_subtotal
    change_subtotal(price.cents * quantity)
  end

  def calculate_taxes
    line_item_taxes.destroy_all
    total_tax_amount = 0
    total_tax_rate = 0.0

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
    required_tax_rates.each do |tax_rate|
      lit = create_line_item_tax(tax_rate)

      total_tax_rate += lit.used_tax_rate
      total_tax_amount += lit.tax_amount.cents
    end

    self.total_tax_rate = total_tax_rate
    change_tax(total_tax_amount)
  end

  def required_tax_rates
    default_tax_rates.merge(overloaded_tax_rates).values
  end

  def create_line_item_tax(tax_rate)
    tax_amount = calculate_individual_tax_amount(tax_rate.rate)

    line_item_taxes.create(tax_rate: tax_rate, used_tax_rate: tax_rate.rate,
                           tax_amount: tax_amount)
  end

  def default_tax_rates
    tax_rates_hash(site.primary_tax_category)
  end

  def tax_rates_hash(tax_category)
    tax_rates = TaxRate.required_for_location(geo_hierarchy, tax_category)

    tax_rates.inject({}) do |hash, tax_rate|
      hash.merge(tax_rate.priority => tax_rate)
    end
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

  def calculate_individual_tax_amount(used_tax_rate)
    if prices_include_tax?
      tax_prices_inclusive(subtotal, used_tax_rate)
    else
      tax_prices_exclusive(subtotal, used_tax_rate)
    end
  end

  def prices_include_tax?
    site.preferences.prices_include_tax
  end

  def tax_prices_inclusive(amount, rate)
    (amount / (1 + rate)).cents
  end

  def tax_prices_exclusive(amount, rate)
    (amount * rate).cents
  end

  def finalise_total
    if prices_include_tax?
      change_total(subtotal.cents)
    else
      change_total(subtotal.cents + tax.cents)
    end
  end
end
