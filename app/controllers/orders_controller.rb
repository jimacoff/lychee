class OrdersController < ApplicationController
  def create
    @order = Order.create_from_bag(bag, metadata: order_metadata)
    session[:order_id] = @order.id
    redirect_to order_path
  end

  def show
    return redirect_to(shopping_bag_path) unless id

    @order = Order.find(id)
    @countries = Country.all
    @states = State.all

    render("orders/states/#{@order.workflow_state}")
  end

  def update
    @order = Order.find(id)
    update_order_people if order_params
    apply_transition if params[:transition]
    @order.save!

    redirect_to order_path
  end

  private

  CUSTOMER_TRANSITIONS = %w(calculate confirm pay)

  def id
    @id ||= session[:order_id]
  end

  def bag
    ShoppingBag.find(session[:shopping_bag_id])
  end

  def apply_transition
    transition = params[:transition]
    fail('bad transition') unless CUSTOMER_TRANSITIONS.include?(transition)
    @order.send("#{transition}!")
  end

  def update_order_people
    destroy = [@order.customer, @order.recipient].compact.uniq

    create_customer
    if order_params[:use_billing_details_for_shipping]
      @order.recipient = @order.customer
    else
      create_recipient
    end
    @order.save!

    destroy.each(&:destroy!)
  end

  def order_metadata
    e = request.env

    { user_agent: request.user_agent, ip: request.ip,
      country_code: e['HTTP_X_GEOIP_COUNTRY_CODE'],
      geoip_latitude: e['HTTP_X_GEOIP_LATITUDE'],
      geoip_longitude: e['HTTP_X_GEOIP_LONGITUDE'] }
  end

  def order_params
    params[:order]
  end

  def person_params(sym)
    order_params.require(sym).permit(:display_name)
  end

  def address_params(sym)
    order_params[sym].require(:address)
      .permit(:line1, :line2, :line3, :line4, :locality,
              :postcode, :country_id, :state_id)
  end

  def create_customer
    @order.create_customer!(person_params(:customer))
    @order.customer.create_address!(address_params(:customer))
  end

  def create_recipient
    @order.create_recipient!(person_params(:recipient))
    @order.recipient.create_address!(address_params(:recipient))
  end
end
