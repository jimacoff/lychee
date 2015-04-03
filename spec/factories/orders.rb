FactoryGirl.define do
  factory :order do
    status 'created'

    association :customer_address, factory: :address
    association :delivery_address, factory: :address

    trait :with_products do
      after(:create) do |o|
        o.order_lines = create_list(:product_order_line, 5, order: o)
      end
    end
  end
end
