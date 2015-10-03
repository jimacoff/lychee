FactoryGirl.define do
  factory :order do
    status 'created'
    metadata(user_agent: 'Firefox')

    association :customer_address, factory: :address
    association :delivery_address, factory: :address

    trait :with_products do
      after(:create) do |o|
        o.line_items = create_list(:commodity_line_item, 5, order: o)
      end
    end
  end
end
