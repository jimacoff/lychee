FactoryGirl.define do
  factory :preference do
    tax_basis { :delivery }
    prices_include_tax { false }
  end
end
