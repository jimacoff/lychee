FactoryGirl.define do
  factory :preference do
    tax_basis { :shipping }
    prices_include_tax { false }
  end
end
