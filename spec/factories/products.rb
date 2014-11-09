FactoryGirl.define do
  factory :product do
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }

    active true
  end

end
