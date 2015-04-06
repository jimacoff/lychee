FactoryGirl.define do
  factory :site do
    name { Faker::Lorem.sentence }
    currency { 'AUD' }

    after(:create) do |s|
      s.subscriber_address = create :address, site_subscriber_address: s,
                                              site: s
    end

    trait :distribution_address do
      after(:create) do |s|
        s.distribution_address = create :address, site_distribution_address: s,
                                                  site: s
      end
    end
  end
end
