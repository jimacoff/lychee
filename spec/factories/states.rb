FactoryGirl.define do
  factory :state do
    name { Faker::Lorem.word }
    iso_code { Faker::Lorem.word }
    postal_format { Faker::Lorem.word }
    tax_code { Faker::Lorem.word }

    country
  end
end
