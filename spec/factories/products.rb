FactoryGirl.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    active true

    after(:build) do |p|
      p.price = Faker::Number.number(4).to_i
    end

    factory :standalone_product do
      after(:create) do |p|
        p.inventory = create(:tracked_inventory, product: p)
      end
    end

    trait :with_categories do
      after(:create) do |p|
        p.category_members << create_list(:category_member, 2,
                                          product: p, site: p.site)
      end
    end
  end
end
