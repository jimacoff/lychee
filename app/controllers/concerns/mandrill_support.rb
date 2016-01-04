require 'mandrill'

module MandrillSupport
  extend ActiveSupport::Concern

  def send_simple_message
    html = render_email_template
    document = Roadie::Document.new html
    document.url_options =
      { host: @site.preferences.hostname,
        protocol: @site.preferences.protocol }

    mandrill = Mandrill::API.new @site.preferences.email_api_key
    message = {
      tags: %w(order, confirmation),
      to: [
        { name: @order.customer.display_name, email: @order.customer.email }
      ],
      track_opens: true,
      track_clicks: false,
      bcc_address: @site.preferences.email_from_address,
      inline_css: false,
      headers: { 'Reply-To' => @site.preferences.email_from_address },
      # 'google_analytics_campaign'=>'message.from_email@example.com',
      # 'google_analytics_domains'=>['example.com'],
      auto_text: true,
      auto_html: false,
      subject: 'Thank you for placing an order',
      html: document.transform,
      subaccount: @site.preferences.email_subaccount_identifier,
      merge: false,
      from_name: @site.preferences.email_from_name,
      from_email: @site.preferences.email_from_address,
      preserve_recipients: false,
      metadata: {},
      important: true,
      url_strip_qs: false
    }
    async = true
    mandrill.messages.send message, async
  rescue Mandrill::Error => e
    Rails.logger.error
    "Order: #{@order.id} - A mandrill error occurred: #{e.class}" \
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
