module TestStore
  class ProductsController < ApplicationController
    def index
      @site = Site.current
      @products = Product.all
    end
  end
end
