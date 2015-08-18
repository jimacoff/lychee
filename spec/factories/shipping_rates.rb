FactoryGirl.define do
  factory :shipping_rate do
    sequence :name do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    description { Faker::Lorem.sentence }

    trait :with_min_weight do
      min_weight 1
    end

    trait :with_max_weight do
      max_weight 1000
    end

    trait :with_min_price do
      min_price { Faker::Number.number(4).to_i + 1 }
    end

    trait :with_max_price do
      max_price { Faker::Number.number(8).to_i + 10 }
    end

    trait :with_regions do
      after(:create) do |sr|
        create_list(:shipping_rate_region, 5, shipping_rate: sr)
      end
    end

    factory :shipping_rate_with_price_range do
      with_min_price
      with_max_price
    end
  end
end
