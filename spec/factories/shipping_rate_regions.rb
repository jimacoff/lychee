FactoryGirl.define do
  factory :shipping_rate_region do
    shipping_rate
    country

    price { Faker::Number.number(4).to_i }

    trait :with_state do
      state
    end
  end
end
