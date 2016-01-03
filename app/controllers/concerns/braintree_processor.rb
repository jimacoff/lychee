require 'braintree'

# rubocop:disable Metrics/ModuleLength
module BraintreeProcessor
  extend ActiveSupport::Concern

  private

  def populate_braintree_data
    @braintree = {
      merchant_id: @site.preferences.braintree_merchant_id,
      client_token: session[:client_token] || generate_client_token
    }
  end

  def generate_client_token
    session[:client_token] = braintree_gateway.client_token.generate
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def generate_transaction
    braintree_gateway.transaction.sale(
      order_id: @order.id,
      amount: @order.total,
      tax_amount: @order.total_tax,
      payment_method_nonce: params[:payment_method_nonce],
      customer: {
        first_name: @order.customer.display_name.slice(0, 254),
        email: @order.customer.email
      },
      billing: {
        first_name: @order.customer.display_name.slice(0, 254),
        country_code_alpha2: @order.customer.address.country.iso_alpha2,
        region: @order.customer.address.state.postal_format,
        postal_code: @order.customer.address.postcode,
        locality: @order.customer.address.locality,
        street_address: braintree_street_address(@order.customer.address)
      },
      shipping: {
        first_name: @order.recipient.display_name.slice(0, 254),
        country_code_alpha2: @order.recipient.address.country.iso_alpha2,
        region: @order.recipient.address.state.postal_format,
        postal_code: @order.recipient.address.postcode,
        locality: @order.recipient.address.locality,
        street_address: braintree_street_address(@order.recipient.address)
      },
      options: {
        submit_for_settlement: true,
        paypal: {
          description:
            @site.name.downcase.strip.slice(0, 126)
        }
      }
    )
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def braintree_street_address(address)
    combined_address = "#{address.line1} #{address.line2}"
    combined_address.slice(0, 254)
  end

  def braintree_gateway
    Braintree::Gateway.new(
      environment: @site.preferences.braintree_environment.to_sym,
      merchant_id: @site.preferences.braintree_merchant_id,
      public_key: @site.preferences.braintree_public_key,
      private_key: @site.preferences.braintree_private_key
    )
  end

  def process_payment
    braintree_response = generate_transaction

    if braintree_response.success?
      handle_successful_payment(braintree_response)
      render_state_template('orders/states/finalized')
    else
      handle_unsuccessful_payment(braintree_response)
      render_state_template('orders/states/payment-error')
    end
  end

  def handle_successful_payment(processor_response)
    @order.finalize!
    @order.shopping_bag.finalize!

    transaction = generate_payment_log(processor_response, 'success')
    @order.transaction_history << transaction
    @order.save!

    reset_session
    send_simple_message
  end

  def handle_unsuccessful_payment(processor_response)
    transaction = generate_payment_log(processor_response, 'failure')
    @order.transaction_history << transaction
    @order.save!
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def generate_payment_log(braintree_response, internal_state)
    if braintree_response.transaction.nil?
      return {
        internal_state: 'transaction creation error',
        message: braintree_response.message
      }.to_json
    end

    t = braintree_response.transaction
    cc = t.credit_card_details
    pp = t.paypal_details

    {
      internal_state: internal_state,
      id: t.id,
      created_at: t.created_at,
      updated_at: t.updated_at,
      status: t.status,
      amount: t.amount,
      currency_iso_code: t.currency_iso_code,
      type: t.type,
      payment_instrument_type: t.payment_instrument_type,
      processor_response_code: t.processor_response_code,
      processor_response_text: t.processor_response_text,
      processor_settlement_response_code: t.processor_settlement_response_code,
      processor_settlement_response_text: t.processor_settlement_response_text,
      cvv_response_code: t.cvv_response_code,
      credit_card_details: {
        bin: cc.bin,
        card_type: cc.card_type,
        cardholder_name: cc.cardholder_name,
        country_of_issuance: cc.country_of_issuance,
        image_url: cc.image_url,
        issuing_bank: cc.issuing_bank,
        last_4: cc.last_4,
        masked_number: cc.masked_number,
        expiration_date: cc.expiration_date,
        risk_data: {
          id: cc.try(:risk_data).try(:id),
          decision: cc.try(:risk_data).try(:decision)
        }
      },
      paypal_details: {
        authorization_id: pp.authorization_id,
        capture_id: pp.capture_id,
        payment_id: pp.payment_id,
        image_url: pp.image_url,
        payer_email: pp.payer_email,
        payer_first_name: pp.payer_first_name,
        payer_last_name: pp.payer_last_name,
        payer_id: pp.payer_id,
        seller_protection_status: pp.seller_protection_status,
        transaction_fee_amount: pp.transaction_fee_amount,
        transaction_fee_currency_iso_code:
          pp.transaction_fee_currency_iso_code
      }
    }.to_json
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
# rubocop:enable Metrics/ModuleLength
