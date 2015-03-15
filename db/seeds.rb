unless ENV['ZEPILY_DEV'].to_i == 1
  $stderr.puts <<-EOF
  This is a destructive action, intended only for use in development
  environments where you wish to replace ALL data with generated sample data.
  If this is what you want, set the ZEPILY_DEV environment variable to 1 before
  attempting to seed your database.
  EOF
  fail('Not proceeding, missing ZEPILY_DEV=1 environment variable')
end

require 'faker'
require 'factory_girl'

include FactoryGirl::Syntax::Methods

ActiveRecord::Base.transaction do

  site = FactoryGirl.create :site
  Site.current = site

  # Categories
  men = Category.create(name: 'Mens Clothing',
                        description: Faker::Lorem.sentence)
  men_casual = Category.create(name: 'Mens Casual',
                               description: Faker::Lorem.sentence,
                               parent_category: men)
  women = Category.create(name: 'Womens Clothing',
                          description: Faker::Lorem.sentence)
  women_casual = Category.create(name: 'Womens Casual',
                                 description: Faker::Lorem.sentence,
                                 parent_category: women)

  # Traits
  sizes = %w(small medium large x-large xx-large)
  mens_formal_colors = (1..5).map { Faker::Commerce.color }
  womens_jumper_colors = (1..5).map { Faker::Commerce.color }

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

    product = Product.create!(name: name, description: desc,
                             categories: [men, men_casual],
                             price: Faker::Number.number(6).to_i)

    variation = Variation.create(order: 1, product: product,
                                 trait: size_trait)
    variation2 = Variation.create(order: 2, product: product,
                                  trait: mens_formal_color_trait)

    variation_instances = [size_trait.default_values, mens_formal_colors]
                          .inject(&:product).map(&:flatten)

    variation_instances.each do |vi|
      inventory = Inventory.create(tracked: true,
                                   quantity: Faker::Number.number(3),
                                   back_orders: false)
      variant = Variant.create(product: product, inventory: inventory,
                               price: Faker::Number.number(6).to_i)

      VariationInstance.create(variation: variation, variant: variant,
                               value: vi[0])
      VariationInstance.create(variation: variation2, variant: variant,
                               value: vi[1])
    end

    product.add_tag('clothing')
    product.add_tag('casual')
    product.save!
  end

  # Womens Casual Shirts
  (1..5).each do
    name = "Casual #{Faker::Lorem.word} shirt"
    desc = "A casual shirt made from 100% #{Faker::Lorem.word}"

    product = Product.create(name: name, description: desc,
                             categories: [women, women_casual],
                             price: Faker::Number.number(6).to_i)

    variation = Variation.create(order: 1, product: product,
                                 trait: size_trait)
    variation2 = Variation.create(order: 2, product: product,
                                  trait: womens_casual_color_trait)

    variation_instances = [size_trait.default_values, womens_jumper_colors]
                          .inject(&:product).map(&:flatten)

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
    product.add_tag('casual')
    product.save!
  end
end
