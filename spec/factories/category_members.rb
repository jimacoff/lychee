FactoryGirl.define do
  factory :category_member do
    product
    category
    description { Faker::Lorem.sentence }
  end
end
