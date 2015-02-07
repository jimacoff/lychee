FactoryGirl.define do
  factory :site do
    name { Faker::Lorem.sentence }
  end
end
