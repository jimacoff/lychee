FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "#{Faker::Commerce.product_name}#{n}"
    end

    short_description { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
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

    trait :with_variants do
      after(:create) do |p|
        # Subscriber wide product traits
        sizes = %w(small medium large)
        colors = %w(blue red green)

        size_trait = create(:trait, name: 'Size',
                                    display_name: Faker::Lorem.sentence,
                                    default_values: sizes)

        color_trait = create(:trait, name: 'Color',
                                     display_name: Faker::Lorem.sentence,
                                     default_values: colors)

        # Product specific variations
        var_size = create(:variation, order: 1, product: p, trait: size_trait)
        var_color = create(:variation, order: 2, product: p, trait: color_trait)

        variation_instances = [size_trait.default_values,
                               color_trait.default_values].inject(&:product)

        variation_instances.each do |vi|
          variant = create(:variant, product: p)

          create :variation_instance, variation: var_size,
                                      variant: variant,
                                      value: vi[0]
          create :variation_instance, variation: var_color,
                                      variant: variant,
                                      value: vi[1]
        end
      end
    end
  end
end
