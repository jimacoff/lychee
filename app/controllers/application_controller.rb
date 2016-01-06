require 'zepily/critical_error'

class ApplicationController < ActionController::Base
  before_action do
    @site = Site.current =
      Tenant.eager_load(:site).where(identifier: request.host).take!.site
  end

  private

  def template
    template = File.join(base_path, site_path, controller_template)
    return File.read(template) if File.exist?(template)

    fail(Zepily::CriticalError, "Template file #{template} does not exist")
  end

  def site_path
    @site.id.to_s
  end

  def base_path
    Rails.configuration.zepily.sites.themes.base
  end
end
