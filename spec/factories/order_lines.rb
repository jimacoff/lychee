FactoryGirl.define do
  factory :order_line do
    order
    quantity { Faker::Number.number(1).to_i + 1 }
    price { Faker::Number.number(4).to_i + 1 }

    factory :product_order_line do
      product
    end

    factory :variant_order_line do
      variant
    end
  end
end
