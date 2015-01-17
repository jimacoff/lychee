FactoryGirl.define do
  factory :fancy_shirts, class: 'Product' do
    name 'Fancy Shirt'
    description '100% cotton shirt that everyone loves'
    active true

    after(:create) do |shirt|
      size = create :trait, name: 'size', display_name: 'Size',
                            description: 'Your shirt size'
      color = create :trait, name: 'color', display_name: 'Color',
                             description: 'Color of the shirt'

      shirt_size = create :variation, product: shirt, trait: size
      shirt_color = create :variation, product: shirt, trait: color

      shirt_blue_small = create :variant,
                                product: shirt,
                                description: "Small/Blue #{shirt.description}"

      shirt_green_small = create :variant,
                                 product: shirt,
                                 description: "Small/Green #{shirt.description}"

      create :variation_instance, variation: shirt_size,
                                  variant: shirt_blue_small, value: 'small'
      create :variation_instance, variation: shirt_color,
                                  variant: shirt_blue_small, value: 'blue'

      create :variation_instance, variation: shirt_size,
                                  variant: shirt_green_small, value: 'small'
      create :variation_instance, variation: shirt_color,
                                  variant: shirt_green_small, value: 'green'
    end
  end
end
