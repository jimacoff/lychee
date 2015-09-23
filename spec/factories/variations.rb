FactoryGirl.define do
  factory :variation do
    product
    association :trait
    sequence :order
  end
end
