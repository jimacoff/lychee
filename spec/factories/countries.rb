FactoryGirl.define do
  factory :country do
    name { Faker::Address.country }
    iso_alpha2 { Faker::Lorem.word }
    iso_alpha3 { Faker::Lorem.word }
  end
end
