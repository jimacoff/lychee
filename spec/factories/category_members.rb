FactoryGirl.define do
  factory :category_member do
    category

    factory :product_category_member do
      product
    end
  end
end
