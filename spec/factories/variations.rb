FactoryGirl.define do
  factory :variation do
    association :product
    association :trait
    sequence :order
  end
end
