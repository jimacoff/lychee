FactoryGirl.define do
  factory :order do
    shopping_bag
    metadata(user_agent: 'Firefox')

    association :customer, factory: [:person, :with_address]
    association :recipient, factory: [:person, :with_address]

    trait :with_cli do
      after(:create) do |o|
        create_list(:commodity_line_item, 2, :with_product, order: o)
        create_list(:commodity_line_item, 2, :with_variant, order: o)
      end
    end

    trait :with_sli do
      after(:create) do |o|
        create(:shipping_line_item, order: o)
      end
    end
  end
end
