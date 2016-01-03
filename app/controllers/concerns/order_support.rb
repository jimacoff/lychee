module OrderSupport
  extend ActiveSupport::Concern

  private

  def id
    @id ||= session[:order_id]
  end

  def bag
    @order.try(:bag) || ShoppingBag.find(session[:shopping_bag_id])
  end

  def populate_order
    @order = Order.find(id)
  end

  def order_params
    params[:order]
  end

  def person_params(sym)
    order_params.require(sym).permit(:display_name, :email, :phone_number)
  end

  def address_params(sym)
    order_params[sym].require(:address)
      .permit(:line1, :line2, :line3, :line4, :locality,
              :postcode, :country_id, :state_id)
  end

  CUSTOMER_TRANSITIONS = %w(store_details store_shipping confirm cancel)
  def apply_transition
    transition = params[:transition]
    fail('bad transition') unless CUSTOMER_TRANSITIONS.include?(transition)
    @order.send("#{transition}!")
  end

  def request_metadata
    e = request.env

    { user_agent: request.user_agent, ip: request.ip,
      country_code: e['HTTP_X_GEOIP_COUNTRY_CODE'],
      geoip_latitude: e['HTTP_X_GEOIP_LATITUDE'],
      geoip_longitude: e['HTTP_X_GEOIP_LONGITUDE'] }
  end
end
