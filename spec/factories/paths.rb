FactoryGirl.define do
  factory :path do
    segment { Faker::Internet.slug }
  end
end
