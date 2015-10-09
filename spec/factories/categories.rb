FactoryGirl.define do
  factory :category do
    sequence :name do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    description { Faker::Lorem.sentence }

    trait :with_subcategories do
      after(:create) do |cat|
        cat.subcategories.push create_list(:category, 4, parent_category: cat)
      end
    end

    trait :routable do
      after(:create) do |c|
        c.create_default_path
      end
    end
  end
end
