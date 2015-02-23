class Country < ActiveRecord::Base
  has_paper_trail

  validates :name, :iso_alpha2, :iso_alpha3, presence: true
end
