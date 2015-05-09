FactoryGirl.define do
  factory :base_line_item, class: :line_item do
    order
  end

  factory :commodity_line_item do
    order
    association :product, factory: :standalone_product
    quantity { Faker::Number.number(1).to_i + 1 }
  end

  factory :commodity_variant_line_item, class: :commodity_line_item do
    order
    variant
    quantity { Faker::Number.number(1).to_i + 1 }
  end

  factory :shipping_line_item do
    order
    association :shipping_rate_region
  end
end
