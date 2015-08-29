class ShoppingCartOperation < ActiveRecord::Base
  include CommodityReference

  belongs_to :shopping_cart

  valhammer
end
