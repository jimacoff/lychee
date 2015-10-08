FactoryGirl.define do
  factory :image_file do
    association :image, image_files: false

    width { "#{rand(100..800)}" }
    height { "#{rand(100..800)}" }
    default_image { false }
    original_image { false }

    trait :original_image do
      original_image true
    end

    trait :default_image do
      default_image true
    end

    trait :routable do
      after(:create) do |image_file|
        image_file.create_default_path
      end
    end
  end
end
