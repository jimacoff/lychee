FactoryGirl.define do
  factory :tenant do
    identifier { Faker::Internet.domain_name }

    site
  end
end
