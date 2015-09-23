FactoryGirl.define do
  factory :variation_value do
    variation
    value { Faker::Lorem.word }
    sequence :order
  end
end
