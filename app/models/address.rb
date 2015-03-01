class Address < ActiveRecord::Base
  belongs_to :country

  include ParentSite
  include Metadata

  has_paper_trail
  valhammer

  validates :country, presence: true
end
