FactoryGirl.define do
  factory :line_item do
    order
    quantity { Faker::Number.number(1).to_i + 1 }
    price { Faker::Number.number(4).to_i + 1 }

    factory :product_line_item do
      product
    end

    factory :variant_line_item do
      variant
    end
  end
end
