FactoryGirl.define do
  factory :site do
    name { Faker::Lorem.sentence }
    currency { 'AUD' }

    after(:create) do |s|
      s.subscriber_address = create :address, site_subscriber_address: s,
                                              site: s
    end
  end
end
