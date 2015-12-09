FactoryGirl.define do
  factory :order do
    metadata(user_agent: 'Firefox')

    association :customer, factory: [:person, :with_address]
    association :recipient, factory: [:person, :with_address]

    trait :with_cli do
      after(:create) do |o|
        create_list(:commodity_line_item, 2, :with_product, order: o)
        create_list(:commodity_line_item, 2, :with_variant, order: o)
      end
    end
  end
end
