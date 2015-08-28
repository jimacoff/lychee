FactoryGirl.define do
  factory :preference do
    tax_basis { :delivery }
    prices_include_tax { false }
    reserved_paths do
      { 'blog' => "/#{Faker::Internet.slug}",
        'blog_articles' => "/#{Faker::Internet.slug}",
        'blog_categories' => "/#{Faker::Internet.slug}",
        'blog_tags' => "/#{Faker::Internet.slug}",
        'products' => "/#{Faker::Internet.slug}",
        'categories' => "/#{Faker::Internet.slug}",
        'images' => "/_assets/#{Faker::Internet.slug}" }
    end
  end
end
