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

    trait :with_variants do
      after(:create) do |p|
        # Subscriber wide product traits
        sizes = %w(small medium large)
        colors = %w(blue red green)

        size_trait = Trait.create(name: 'Size',
                                  display_name: Faker::Lorem.sentence,
                                  default_values: sizes)

        color_trait = Trait.create(name: 'Color',
                                   display_name: Faker::Lorem.sentence,
                                   default_values: colors)

        # Product specific variations
        var_size = Variation.create(order: 1, product: p, trait: size_trait)
        var_color = Variation.create(order: 2, product: p, trait: color_trait)

        variation_instances = [size_trait.default_values,
                               color_trait.default_values].inject(&:product)

        variation_instances.each do |vi|
          variant = create(:variant, product: p)

          VariationInstance.create(variation: var_size, variant: variant,
                                   value: vi[0])
          VariationInstance.create(variation: var_color, variant: variant,
                                   value: vi[1])
        end
      end
    end
  end
end
