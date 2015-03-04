FactoryGirl.define do
  factory :order do
    number { Faker::Number.number(3) }
    status 'created'

    association :customer_address, factory: :address
    association :delivery_address, factory: :address
  end
end
