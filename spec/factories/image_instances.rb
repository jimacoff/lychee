FactoryGirl.define do
  factory :image_instance do
    image
    association :imageable, factory: :category_member
    sequence :order

    trait :for_product_category do
    end

    trait :for_product do
      association :imageable, factory: :product
    end

    trait :for_category do
      association :imageable, factory: :category
    end

    trait :for_variation_instance do
      association :imageable, factory: :variation_instance
    end
  end
end
