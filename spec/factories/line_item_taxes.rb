FactoryGirl.define do
  factory :line_item_tax do
    association :line_item, factory: [:commodity_line_item, :with_product]
    tax_rate
  end
end
