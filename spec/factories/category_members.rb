FactoryGirl.define do
  factory :category_member do
    category
    description { Faker::Lorem.sentence }

    factory :product_category_member do
      product
    end
  end
end
