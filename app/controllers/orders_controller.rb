class OrdersController < ApplicationController
  after_action :saas_template, only: [:show, :payment]

  include OrderSupport
  include BraintreeProcessor
  include MandrillSupport

  def create
    unless @site.preferences.braintree_configured
      return render_state_template('orders/states/error')
    end

    @order = Order.create_from_bag(bag, metadata: request_metadata)
    session[:order_id] = @order.id
    redirect_to order_path
  end

  def show
    return redirect_to(shopping_bag_path) unless id

    populate_show_data
    render_state_template("orders/states/#{@order.workflow_state}")
  end

  def update
    return redirect_to(shopping_bag_path) unless id

    update_order
    perform_order_calculations
    redirect_to order_path
  end

  def payment
    return redirect_to(shopping_bag_path) unless id

    populate_order
    @order.with_lock do
      unless @order.current_state == :pending
        reset_session
        return redirect_to(shopping_bag_path)
      end

      process_payment
    end
  end

  private

  def saas_template
    new_body = template.gsub(/__yield_checkout__/, response.body)
    response.body = new_body
  end

  def populate_show_data
    populate_order
    populate_address_data if @order.current_state == :details
    populate_shipping_rates if @order.current_state == :shipping
    populate_braintree_data if @order.current_state == :pending
  end

  def update_order
    populate_order
    update_order_people if @order.current_state == :details
    update_order_shipping if @order.current_state == :shipping
    apply_transition if params[:transition]
  end

  def perform_order_calculations
    return unless @order.current_state == :pending

    @order.perform_calculations
    @order.save!
  end

  def update_order_people
    destroy = [@order.customer, @order.recipient].compact.uniq
    create_customer
    if order_params[:use_billing_details_for_shipping] == '1'
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

  def create_customer
    @order.create_customer!(person_params(:customer))
    @order.customer.create_address!(address_params(:customer))
  end

  def create_recipient
    @order.create_recipient!(person_params(:recipient))
    @order.recipient.create_address!(address_params(:recipient))
  end

  def populate_address_data
    @countries = @site.countries
    @states = @countries.first.states
  end

  def populate_shipping_rates
    return unless @order.recipient.present?

    location = @order.recipient.address.to_geographic_hierarchy
    subtotal = @order.transient_subtotal_cents
    weight = @order.transient_weight

    @shipping_rates = ShippingRate.supports_location(location)
                      .satisfies_price(subtotal)
                      .satisfies_weight(weight)
  end

  def render_state_template(state_template)
    render template: state_template, layout: false
  end

  def controller_template
    Rails.configuration.zepily.sites.themes.templates.checkout
  end
end
