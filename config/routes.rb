require 'dasherized_routes'

Rails.application.routes.draw do
  self.class.include DasherizedRoutes

  resource :shopping_bag, path: '/shop/bag', only: %i(show update destroy) do
    post '' => 'shopping_bags#add'
  end

  resources :pages
end
