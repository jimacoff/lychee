FactoryGirl.define do
  factory :state do
    sequence :name do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    sequence :iso_code do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    postal_format { Faker::Lorem.word }

    country
  end
end
