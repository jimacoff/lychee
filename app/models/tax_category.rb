class TaxCategory < ActiveRecord::Base
  include ParentSite
  include Metadata

  belongs_to :site_primary_tax_category, class_name: 'Site',
                                         foreign_key:
                                          'site_primary_tax_category_id'

  has_many :tax_rates

  has_paper_trail
  valhammer
end
