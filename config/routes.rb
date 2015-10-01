require 'dasherized_routes'

Rails.application.routes.draw do
  self.class.include DasherizedRoutes

  resource :shopping_cart, only: %i(show update destroy) do
    post '' => 'shopping_carts#add'
  end

  resources :pages
end
