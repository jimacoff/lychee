require 'sparkpost'

module SparkpostSupport
  extend ActiveSupport::Concern

  def send_simple_message
    html = render_email_template
    document = Roadie::Document.new html
    document.url_options =
      { host: @site.preferences.hostname,
        protocol: @site.preferences.protocol }

    sp = SparkPost::Client.new @site.preferences.email_api_key
		sp.transmission.send_message(@order.customer.email,
																 @site.preferences.email_from_address,
																 'Thank you for placing an order',
																 document.transform)

		sp.transmission.send_message(@site.preferences.email_from_address,
																 @site.preferences.email_from_address,
																 'Thank you for placing an order',
																 document.transform)

  rescue SparkPost::DeliveryException => e
    Rails.logger.error
    "Order: #{@order.id} - A sparkpost error occurred: #{e.class}" \
      "\n#{e.message}"
  end

  def render_email_template
    email_template.gsub(/__yield_email__/,
                        render_to_string(layout: false,
                                         template:
                                           'orders/email/confirm_order'))
  end

  def email_template
    email_templates = Rails.configuration.zepily.sites.themes.templates.email
    template =
      File.join(base_path, site_path, email_templates.confirm_order)

    return File.read(template) if File.exist?(template)

    fail(Zepily::CriticalError,
         "Email template file #{template} does not exist")
  end
end
