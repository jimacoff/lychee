class Tenant < ActiveRecord::Base
  belongs_to :site

  validates :site, :identifier, presence: true
end
