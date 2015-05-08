class TaxRate < ActiveRecord::Base
  include ParentSite
  include ParentCountry
  include ParentState
  include GeographicHierarchy
  include Metadata
  include Enablement

  ##
  # This is somewhat funky so it is worthy of some explanation.
  #
  # Firstly it makes use of Postgres window functions per:
  # http://www.postgresql.org/docs/9.4/static/tutorial-window.html
  #
  # The need here is to retrieve the most specific TaxRate per priority
  # within the stated tax_category. Priority essentially groups like rates i.e.
  # You have a tax_rate called 'GST' that is always 10% except for in the
  # postcode 4000 where it needs to be overriden to 11% for whatever
  # political reason.
  #
  # The most specific rate is determined by ltree
  # query. Assuming we have 2 records with the following geographic_hierachy:
  #
  # 'au' (1)
  # 'au.qld.4000' (2)
  #
  # When determining the tax rate for a an address that has a
  # geographic_hierarchy of 'au.qld.4300.goodna' or 'au.nsw.2480.lismore'
  # number 1 above is the most specific match.
  # For 'au.qld.4000.brisbane' however both rates match
  # according to ltree search but 2 is the most specific and hence the result.
  #
  # See the specs for more examples on how this plays out, but it allows quite
  # detailed taxation requirements to be applied and they get weird in various
  # parts of the world.
  ##
  scope :required_for_location, lambda { |geographic_hierarchy, tax_category|
    TaxRate.find_by_sql([
      %(
        SELECT *
        FROM (
          SELECT
            t.*,
            ROW_NUMBER() OVER
              (PARTITION BY priority ORDER BY geographic_hierarchy DESC) AS r
          FROM tax_rates AS t
          WHERE
            t.site_id = ? AND
            t.enabled = true AND
            t.tax_category_id = ? AND
            t.geographic_hierarchy @> ?) AS x
        WHERE x.r <= 1
      ), tax_category.site.id, tax_category.id, geographic_hierarchy
    ])
  }

  belongs_to :tax_category

  has_paper_trail
  valhammer

  validates :rate, numericality: { greater_than_or_equal_to: 0.0,
                                   less_than_or_equal_to: 1.0 }

  validates :geographic_hierarchy, uniqueness: { scope: [:site,
                                                         :tax_category,
                                                         :priority] }

  def valid_state
  end
end
