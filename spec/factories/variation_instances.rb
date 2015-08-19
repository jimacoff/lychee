FactoryGirl.define do
  factory :variation_instance do
    sequence :name do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    description { Faker::Lorem.sentence }
    sequence :value do |n|
      "#{Faker::Lorem.word}#{n}"
    end

    after(:build) do |vi|
      product = FactoryGirl.create(:product)
      vi.variant = create(:variant, product: product)
      vi.variation = create(:variation, product: product)
    end
  end
end
