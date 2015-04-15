FactoryGirl.define do
  factory :commodity_line_item do
    order
    product
    quantity { Faker::Number.number(1).to_i + 1 }
    price { Faker::Number.number(4).to_i + 1 }
  end

  factory :commodity_variant_line_item, class: :commodity_line_item do
    order
    variant
    quantity { Faker::Number.number(1).to_i + 1 }
    price { Faker::Number.number(4).to_i + 1 }
  end
end
