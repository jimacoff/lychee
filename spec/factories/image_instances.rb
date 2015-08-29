FactoryGirl.define do
  factory :image_instance do
    image
    association :imageable, factory: :product_category_member
  end
end
