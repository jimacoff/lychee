require 'dasherized_routes'

Rails.application.routes.draw do
  self.class.include DasherizedRoutes

  resource :shopping_cart, only: %i(show update destroy)
  resources :pages
end
