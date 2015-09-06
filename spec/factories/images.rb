FactoryGirl.define do
  factory :image do
    name { Faker::Lorem.word }
    internal_name { SecureRandom.hex }
    extension { Faker::Lorem.word }
    description { Faker::Lorem.sentence }

    trait :with_image_files do
      after(:create) do |image|
        image.image_files = create_list(:image_file, 5, image: image)
        image.image_files.first.update(original_image: true)
        image.image_files.last.update(default_image: true)
      end
    end
  end
end
