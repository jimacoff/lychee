require 'dasherized_routes'

Rails.application.routes.draw do
  self.class.include DasherizedRoutes

  resources :pages
end
