FactoryGirl.define do
  factory :image_file do
    image

    filename { "#{Faker::Lorem.word}.png" }
    width { "#{rand(100..800)}" }
    default_image { false }
    original_image { false }

    trait :original_image do
      original_image true
    end

    trait :default_image do
      default_image true
    end
  end
end
