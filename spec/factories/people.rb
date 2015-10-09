FactoryGirl.define do
  factory :person do
    display_name Faker::Name.name

    trait :with_address do
      after(:create) do |person|
        create(:address, person: person)
        person.address(true)
      end
    end
  end
end
