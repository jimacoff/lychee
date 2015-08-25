FactoryGirl.define do
  factory :image do
    description { Faker::Lorem.sentence }

    trait :with_image_files do
      after(:create) do |image|
        image.image_files = create_list(:image_file, 3, image: image)
      end
    end
  end
end
