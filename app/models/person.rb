class Person < ActiveRecord::Base
  has_one :address, dependent: :destroy

  valhammer
end
