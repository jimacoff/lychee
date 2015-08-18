FactoryGirl.define do
  factory :state do
    sequence :name do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    iso_code { Faker::Lorem.word }
    postal_format { Faker::Lorem.word }

    country
  end
end
