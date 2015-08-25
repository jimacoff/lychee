FactoryGirl.define do
  factory :preference do
    tax_basis { :delivery }
    prices_include_tax { false }
    reserved_paths do
      { 'blog' => "/b-#{Faker::Internet.slug}",
        'blog_articles' => "/ba-#{Faker::Internet.slug}",
        'blog_categories' => "/bc-#{Faker::Internet.slug}",
        'blog_tags' => "/bt-#{Faker::Internet.slug}",
        'products' => "/p-#{Faker::Internet.slug}",
        'categories' => "/c-#{Faker::Internet.slug}",
        'images' => "/_assets/i-#{Faker::Internet.slug}",
        # TODO: Restrict to /shopping-cart
        'shopping_cart' => "/sc-#{Faker::Internet.slug}" }
    end
  end
end
