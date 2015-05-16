FactoryGirl.define do
  factory :order_tax do
    order
    tax_rate
  end
end
