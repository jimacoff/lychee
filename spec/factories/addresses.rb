FactoryGirl.define do
  factory :address do
    line1 { Faker::Address.secondary_address }
    line2 { Faker::Address.street_address }
    locality { Faker::Address.city }
    postcode { Faker::Address.zip }

    country

    trait :with_state do
      after(:build) do |addr|
        addr.state = create(:state, country: addr.country)
      end
    end
  end
end
