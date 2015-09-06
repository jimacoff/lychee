class ApplicationController < ActionController::Base
  before_action do
    @site = Site.current = Tenant.where(identifier: request.host).take!.site
  end
end
