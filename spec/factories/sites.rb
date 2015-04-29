FactoryGirl.define do
  factory :site do
    name { Faker::Lorem.sentence }
    currency { 'AUD' }
    prices_include_tax { true }

    after(:create) do |s|
      s.primary_tax_category = create :tax_category,
                                      site_primary_tax_category: s,
                                      site: s
      s.tax_categories << s.primary_tax_category

      s.subscriber_address = create :address, site_subscriber_address: s,
                                              site: s
    end
  end
end
