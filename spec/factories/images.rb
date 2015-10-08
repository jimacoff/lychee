FactoryGirl.define do
  factory :image do
    transient do
      image_files true
    end

    name { Faker::Lorem.word }
    internal_name { SecureRandom.hex }
    extension { Faker::Lorem.word }
    description { Faker::Lorem.sentence }

    after(:create) do |image, eval|
      if eval.image_files
        image.image_files = create_list(:image_file, 5, image: image)
        image.image_files.first.update(original_image: true)
        image.image_files.last.update(default_image: true)
      end
    end

    trait :routable do
      after(:create) do |image|
        image.image_files.map(&:create_default_path)
      end
    end
  end
end
