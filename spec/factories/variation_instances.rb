FactoryGirl.define do
  factory :variation_instance do
    sequence :name do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    description { Faker::Lorem.sentence }
    sequence :value do |n|
      "#{Faker::Lorem.word}#{n}"
    end

    variant
    variation
  end
end
