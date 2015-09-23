FactoryGirl.define do
  factory :variation_value do
    variation
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }

    sequence :order
  end
end
