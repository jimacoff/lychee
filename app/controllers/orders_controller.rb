class OrdersController < ApplicationController
  def create
    @order = Order.create_from_bag(bag, metadata: order_metadata)
    session[:order_id] = @order.id
    redirect_to order_path
  end

  def show
    return redirect_to(shopping_bag_path) unless id

    @order = Order.find(id)
    @countries = @site.countries
    @states = @countries.first.states
    @shipping_rates = shipping_rates

    state_template = "orders/states/#{@order.workflow_state}"
    render inline: template.gsub(/__yield_checkout__/,
                                 render_to_string(layout: false,
                                                  template: state_template))
  end

  def update
    @order = Order.find(id)
    update_order_people if @order.current_state == :details
    update_order_shipping if @order.current_state == :shipping
    apply_transition if params[:transition]
    @order.save!

    @order.calculate_total if @order.current_state == :pending
    redirect_to order_path
  end

  private

  CUSTOMER_TRANSITIONS = %w(store_details store_shipping confirm cancel)

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

  def update_order_shipping
    @order.shipping_line_items.each(&:destroy!)
    shipping_rate = ShippingRate.find(params[:shipping_rate])
    location = @order.recipient.address.to_geographic_hierarchy
    sr_region =
      shipping_rate.shipping_rate_regions.supports_location(location).first

    @order.shipping_line_items.create(shipping_rate_region: sr_region)
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
    order_params.require(sym).permit(:display_name, :email, :phone_number)
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

  def shipping_rates
    return unless @order.recipient.present?

    location = @order.recipient.address.to_geographic_hierarchy
    subtotal = @order.transient_subtotal_cents
    weight = @order.transient_weight

    ShippingRate.supports_location(location)
      .satisfies_price(subtotal).satisfies_weight(weight)
  end

  def controller_template
    Rails.configuration.zepily.sites.themes.templates.checkout
  end
end
