FactoryGirl.define do
  factory :site do
    name { Faker::Lorem.sentence }
    currency { 'AUD' }

    transient { enable_on_create true }

    trait :disabled do
      transient { enable_on_create false }
    end

    after(:create) do |s, a|
      s.primary_tax_category = create :tax_category,
                                      site_primary_tax_category: s,
                                      site: s
      s.tax_categories << s.primary_tax_category

      s.preferences = create :preference, site: s

      s.update! subscriber_address: create(:address, site: s),
                enabled: a.enable_on_create
    end
  end
end
