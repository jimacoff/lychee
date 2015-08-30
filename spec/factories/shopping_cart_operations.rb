FactoryGirl.define do
  factory :shopping_cart_operation do
    shopping_cart

    item_uuid { SecureRandom.uuid }
    quantity 1

    trait :for_product do
      product
    end

    trait :for_variant do
      variant
    end
  end
end
