FactoryGirl.define do
  factory :category do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }

    trait :with_subcategories do
      after(:create) do |cat|
        cat.subcategories.push create_list(:category, 4, parent_category: cat)
      end
    end
  end
end
