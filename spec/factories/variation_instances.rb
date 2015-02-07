FactoryGirl.define do
  factory :variation_instance do
    after(:build) do |vi|
      product = FactoryGirl.create(:product)
      vi.variant = create(:variant, product: product)
      vi.variation = create(:variation, product: product)
    end
    value { Faker::Lorem.word }
  end
end
