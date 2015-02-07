FactoryGirl.define do
  factory :variant do
    product
    association :inventory, factory: :tracked_inventory

    trait :with_categories do
      after(:create) do |v|
        v.categories.push create_list(:category, 2)
      end
    end
  end
end
