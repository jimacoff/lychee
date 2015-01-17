FactoryGirl.define do
  factory :trait do
    name { Faker::Lorem.word }
    display_name { name }
    description { Faker::Lorem.sentence }
  end
end
