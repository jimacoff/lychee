class BasicShop
  def self.build
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean

    # Categories
    men = Category.create(name: 'Mens Clothing',
                          description: 'Clothing which is aimed at men')
    men_casual = Category.create(name: 'Mens Casual',
                                 description: 'Casual mens clothing',
                                 parent_category: men)
    women = Category.create(name: 'Womens Clothing',
                            description: 'Clothing which is aimed at women')
    women_casual = Category.create(name: 'Womens Casual',
                                   description: 'Casual womens clothing',
                                   parent_category: women)

    # Traits
    sizes = %w(small medium large x-large xx-large)
    mens_formal_colors = %w(green orange black purple)
    womens_jumper_colors = %w(eggplant ruby malachite)

    size_trait = Trait.create(name: 'Size',
                              display_name: 'The size of an item of clothing',
                              default_values: sizes)
    mens_formal_color_trait =
      Trait.create(name: 'Color',
                   display_name: 'The primary color of mens casual items')

    womens_casual_color_trait =
      Trait.create(name: 'Color',
                   display_name: 'The primary color of womens casual items')

    # Mens Casual Shirts
    (1..5).each do
      name = "Casual #{Faker::Lorem.word} shirt"
      desc = "A casual shirt made from 100% #{Faker::Lorem.word}"

      product = Product.create(name: name, description: desc,
                               categories: [men, men_casual])

      variation = Variation.create(order: 1, product: product,
                                   trait: size_trait)
      variation2 = Variation.create(order: 2, product: product,
                                    trait: mens_formal_color_trait)

      variation_instances = [size_trait.default_values, mens_formal_colors]
                            .inject(&:product)

      variation_instances.each do |vi|
        inventory = Inventory.create(tracked: true,
                                     quantity: Faker::Number.number(3),
                                     back_orders: false)
        variant = Variant.create(product: product, inventory: inventory)

        VariationInstance.create(variation: variation, variant: variant,
                                 value: vi[0])
        VariationInstance.create(variation: variation2, variant: variant,
                                 value: vi[1])
      end

      product.add_tag('clothing')
      product.save!
    end

    # Womens Casual Shirts
    (1..5).each do
      name = "Casual #{Faker::Lorem.word} shirt"
      desc = "A casual shirt made from 100% #{Faker::Lorem.word}"

      product = Product.create(name: name, description: desc,
                               categories: [women, women_casual])

      variation = Variation.create(order: 1, product: product,
                                   trait: size_trait)
      variation2 = Variation.create(order: 2, product: product,
                                    trait: womens_casual_color_trait)

      variation_instances = [size_trait.default_values, womens_jumper_colors]
                            .inject(&:product)

      puts variation_instances

      variation_instances.each do |vi|
        inventory = Inventory.create(tracked: true,
                                     quantity: Faker::Number.number(3),
                                     back_orders: false)

        variant = Variant.create(product: product, inventory: inventory)

        VariationInstance.create(variation: variation, variant: variant,
                                 value: vi[0])
        VariationInstance.create(variation: variation2, variant: variant,
                                 value: vi[1])
      end

      product.add_tag('clothing')
      product.save!
    end
  end
end
