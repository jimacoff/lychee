class OrdersController < ApplicationController
  def create
    @order = Order.create_from_bag(bag, metadata: order_metadata)
    session[:order_id] = @order.id
    redirect_to order_path
  end

  def show
    id = session[:order_id]
    return redirect_to(shopping_bag_path) unless id

    @order = Order.find(id)
  end

  private

  def bag
    ShoppingBag.find(session[:shopping_bag_id])
  end

  def order_metadata
    e = request.env

    { user_agent: request.user_agent, ip: request.ip,
      country_code: e['HTTP_X_GEOIP_COUNTRY_CODE'],
      geoip_latitude: e['HTTP_X_GEOIP_LATITUDE'],
      geoip_longitude: e['HTTP_X_GEOIP_LONGITUDE'] }
  end
end
