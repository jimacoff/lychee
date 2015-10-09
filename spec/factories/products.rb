FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "#{Faker::Commerce.product_name}#{n}"
    end

    description { Faker::Lorem.sentence }
    active true
    markup { "<p>#{Faker::Lorem.paragraph}</p>" }

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

    trait :routable do
      after(:create) do |p|
        p.create_default_path
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
        size_trait.default_values.each_with_index do |v, o|
          create :variation_value,
                 variation: var_size, name: v, order: o
        end

        var_color = create(:variation, order: 2, product: p, trait: color_trait)
        color_trait.default_values.each_with_index do |v, o|
          create :variation_value,
                 variation: var_color, name: v, order: o
        end

        variation_instances = [size_trait.default_values,
                               color_trait.default_values].inject(&:product)

        variation_instances.each do |size_value, color_value|
          variant = create :variant, product: p

          size_variation_value =
            VariationValue.find_by(variation: var_size, name: size_value)
          variant.variation_instances
            .create!(variation: var_size,
                     variation_value: size_variation_value)

          color_variation_value =
            VariationValue.find_by(variation: var_color,
                                   name: color_value)
          variant.variation_instances
            .create!(variation: var_color,
                     variation_value: color_variation_value)
        end
      end
    end
  end
end
