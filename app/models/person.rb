class Person < ActiveRecord::Base
  include ParentSite

  has_one :address, dependent: :destroy

  valhammer
end
