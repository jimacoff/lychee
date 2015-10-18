FactoryGirl.define do
  factory :order do
    metadata(user_agent: 'Firefox')

    association :customer, factory: [:person, :with_address]
    association :recipient, factory: [:person, :with_address]

    trait :with_products do
      after(:create) do |o|
        o.line_items = create_list(:commodity_line_item, 5, order: o)
      end
    end
  end
end
