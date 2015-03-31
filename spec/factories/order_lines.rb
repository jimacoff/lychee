FactoryGirl.define do
  factory :order_line do
    order
    quantity { Faker::Number.number(1).to_i }

    after(:build) do |ol|
      ol.price = Faker::Number.number(4).to_i
    end

    factory :product_order_line do
      product
    end

    factory :variant_order_line do
      variant
    end
  end
end
