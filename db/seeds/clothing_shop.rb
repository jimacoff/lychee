# require 'faker'
# require 'factory_girl'

# include FactoryGirl::Syntax::Methods

# ActiveRecord::Base.transaction do
#   site = FactoryGirl.create :site, name: 'Acme Clothing Shop'
#   Site.current = site

#   Tenant.create!(site: site, identifier: 'localhost')

#   # Categories
#   men = Category.create!(name: 'Mens Clothing',
#                          description: Faker::Lorem.sentence)
#   men_casual = Category.create!(name: 'Mens Casual',
#                                 description: Faker::Lorem.sentence,
#                                 parent_category: men)
#   women = Category.create!(name: 'Womens Clothing',
#                            description: Faker::Lorem.sentence)
#   women_casual = Category.create!(name: 'Womens Casual',
#                                   description: Faker::Lorem.sentence,
#                                   parent_category: women)

#   # Traits
#   sizes = %w(small medium large x-large xx-large)
#   mens_casual_colors = (1..3).map { Faker::Commerce.color }
#   womens_casual_colors = (1..3).map { Faker::Commerce.color }

#   size_trait = Trait.create!(name: 'Size', default_values: sizes,
#                              display_name: 'The size of an item of clothing')

#   mens_casual_color_trait =
#     Trait.create!(name: 'Color',
#                   display_name: 'The primary color of mens casual items')

#   womens_casual_color_trait =
#     Trait.create!(name: 'Color',
#                   display_name: 'The primary color of womens casual items')

#   [
#     [[men, men_casual], mens_casual_color_trait, mens_casual_colors],
#     [[women, women_casual], womens_casual_color_trait, womens_casual_colors]
#   ].each do |(categories, color_trait, color_trait_values)|
#     # 3 Casual Shirts for each gender
#     (1..3).each do |i|
#       name = "Casual #{Faker::Lorem.word} shirt #{i}"
#       description = "A casual shirt made from 100% #{Faker::Lorem.word}"
#       markup = <<-EOF.strip_heredoc
#         <h2>#{Faker::Lorem.word}</h2>
#         <ol>
#           <li>Thing</li>
#           <li>Thing2</li>
#         </ol>

#         #{Faker::Lorem.paragraph}

#         #{Faker::Lorem.paragraph}

#         #{Faker::Lorem.paragraph}

#         #{Faker::Lorem.paragraph}
#       EOF

#       product = Product.create!(name: name, markup: markup,
#                                 description: description,
#                                 price: Faker::Number.number(6).to_i)
#       categories.each_with_index do |c, ci|
#         product.category_members.create!(category: c, description: description,
#                                          order: ci)
#       end

#       size_variation = product.variations.create!(order: 1, trait: size_trait)
#       size_trait.default_values.each_with_index do |v, o|
#         VariationValue.create!(variation: size_variation, name: v, order: o)
#       end

#       color_variation = product.variations.create!(order: 2, trait: color_trait)
#       color_trait_values.each_with_index do |v, o|
#         VariationValue.create!(variation: color_variation, name: v, order: o)
#       end

#       variation_choices = size_trait.default_values.product(color_trait_values)

#       variation_choices.each do |(size_value, color_value)|
#         variant = Variant.create!(product: product,
#                                   price: Faker::Number.number(6).to_i)

#         variant.create_inventory!(tracked: true, back_orders: false,
#                                   quantity: Faker::Number.number(3))

#         size_variation_value =
#           VariationValue.find_by(variation: size_variation, name: size_value)
#         variant.variation_instances
#           .create!(variation: size_variation,
#                    variation_value: size_variation_value)

#         color_variation_value =
#           VariationValue.find_by(variation: color_variation, name: color_value)
#         variant.variation_instances
#           .create!(variation: color_variation,
#                    variation_value: color_variation_value)
#       end

#       product.add_tag('clothing')
#       product.add_tag('casual')
#       product.save!
#     end
#   end
# end
