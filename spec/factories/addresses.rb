FactoryGirl.define do
  factory :address do
    line1 { Faker::Address.secondary_address }
    line2 { Faker::Address.street_address }
    locality { Faker::Address.city }
    region { Faker::Address.state }
    postcode { Faker::Address.zip }

    country
  end
end
