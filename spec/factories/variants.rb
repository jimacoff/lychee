FactoryGirl.define do
  factory :variant do
    product

    after(:create) do |v|
      v.inventory = create(:tracked_inventory, variant: v)
    end

    factory :variant_with_varied_price do
      after(:build) do |v|
        v.price = Faker::Number.number(4).to_i
      end
    end

    trait :with_categories do
      after(:create) do |v|
        v.categories.push create_list(:category, 2)
      end
    end
  end
end
