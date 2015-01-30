FactoryGirl.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }

    active true

    trait :with_categories do
      after(:create) do |p|
        p.categories.push create_list(:category, 2)
      end
    end
  end
end
