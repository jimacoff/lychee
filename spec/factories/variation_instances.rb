FactoryGirl.define do
  factory :variation_instance do
    association :variation
    association :variant
    value { Faker::Lorem.word }
  end
end
