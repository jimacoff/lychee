FactoryGirl.define do
  factory :trait do
    sequence :name do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    display_name { name }
    description { Faker::Lorem.sentence }
  end
end
