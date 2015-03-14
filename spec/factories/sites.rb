FactoryGirl.define do
  factory :site do
    name { Faker::Lorem.sentence }
    currency { 'AUD' }
  end
end
