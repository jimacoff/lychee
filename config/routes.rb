require 'dasherized_routes'

Rails.application.routes.draw do
  self.class.include DasherizedRoutes

  resource :shopping_bag, path: '/shop/bag', only: %i(show update destroy) do
    post '' => 'shopping_bags#add'
  end

  resources :pages

  unless Rails.env.production?
    namespace :test_store do
      blank_msg = 'This page intentionally left blank.'.freeze
      blank = ->(_) { [200, { 'Content-Type' => 'text/plain' }, [blank_msg]] }
      get 'blank', to: blank

      resources :products, only: :index
    end
  end
end
