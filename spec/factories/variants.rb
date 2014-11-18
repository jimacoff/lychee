FactoryGirl.define do
  factory :variant do
    product

    after :build do |variant|
      trait = create :trait
      trait2 = create :trait
      variant.traits = { trait.id => Faker::Lorem.word,
                         trait2.id => Faker::Number.number(3) }
    end
  end
end
