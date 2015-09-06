FactoryGirl.define do
  factory :category_member do
    association :product, factory: :standalone_product
    category
    description { Faker::Lorem.sentence }
  end
end
