FactoryGirl.define do
  factory :category_member do
    category
    description { Faker::Lorem.sentence }
    sequence :order

    after(:build) do |cm|
      cm.product = create :standalone_product, :routable
    end
  end
end
