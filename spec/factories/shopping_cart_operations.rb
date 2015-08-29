FactoryGirl.define do
  factory :shopping_cart_operation do
    shopping_cart

    item_uuid { SecureRandom.uuid }
    quantity 1
  end
end
