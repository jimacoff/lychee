class ApplicationController < ActionController::API
  before_filter do
    @site = Site.current = Tenant.where(identifier: request.host).take!.site
  end
end
