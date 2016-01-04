require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'active_record/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

# TODO: remove?
ActiveRecord::Base.extend Valhammer::Validations

module Lychee
  class Application < Rails::Application
    # Settings in config/environments/* take precedence
    # over those specified here.

    config.eager_load_paths << Rails.root.join('app', 'jobs', 'concerns')
  end
end
