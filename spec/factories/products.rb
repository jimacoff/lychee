FactoryGirl.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }

    active true

    association :inventory, factory: :tracked_inventory
  end
end
