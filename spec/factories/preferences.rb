FactoryGirl.define do
  factory :preference do
    tax_basis { :delivery }
    prices_include_tax { false }
    reserved_uri_paths do
      { 'blog' => "/b-#{Faker::Internet.slug}",
        'blog_articles' => "/ba-#{Faker::Internet.slug}",
        'blog_categories' => "/bc-#{Faker::Internet.slug}",
        'blog_tags' => "/bt-#{Faker::Internet.slug}",
        'products' => "/p-#{Faker::Internet.slug}",
        'categories' => "/c-#{Faker::Internet.slug}",
        'images' => "/_assets/i-#{Faker::Internet.slug}",
        'shopping_bag' => '/shop/bag',
        'checkout' => '/shop/checkout' }
    end

    bag_title { Faker::Lorem.sentence }
    bag_flash { Faker::Lorem.sentence }
    bag_summary_notice { Faker::Lorem.sentence }
    bag_action_continue_shopping { 'Continue Shopping' }
    bag_action_checkout { 'Securely Checkout' }
    bag_empty_notice { Faker::Lorem.sentence }
    bag_empty_start_shopping { Faker::Lorem.word }
  end
end
