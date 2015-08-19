FactoryGirl.define do
  factory :tax_rate do
    tax_category

    rate { 0.1 } # e.g. GST 10%

    sequence :name do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    description { Faker::Lorem.sentence }

    country

    priority { 1 }
  end
end
