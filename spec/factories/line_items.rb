FactoryGirl.define do
  factory :base_line_item, class: :line_item do
    order
  end

  factory :commodity_line_item do
    order
    quantity { Faker::Number.number(1).to_i + 1 }

    trait :with_product do
      association :product, factory: :standalone_product
    end

    trait :with_variant do
      variant
    end
  end

  factory :shipping_line_item do
    order
    association :shipping_rate_region
  end
end
