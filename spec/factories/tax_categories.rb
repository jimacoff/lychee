FactoryGirl.define do
  factory :tax_category do
    sequence :name do |n|
      "#{Faker::Lorem.word}#{n}"
    end
  end
end
