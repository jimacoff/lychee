ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require 'factory_girl_rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
ActiveRecord::Migration.maintain_test_schema!

module SpecSite
  def with_spec_site
    tenant = Tenant.find_by(identifier: '127.0.0.1') ||
             FactoryGirl.create(:tenant, identifier: '127.0.0.1')

    ActionController::TestRequest::DEFAULT_ENV
      .merge!('HTTP_HOST' => tenant.identifier)

    Site.current = tenant.site
    yield
    Site.current = nil
  end
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  # Use FactoryGirl
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  # Supply a site scope when requested
  config.include SpecSite, site_scoped: true
  config.around(:example, :site_scoped) { |e| with_spec_site { e.run } }

  config.around(:example, :debug) do |example|
    old = ActiveRecord::Base.logger
    begin
      ActiveRecord::Base.logger = Logger.new($stderr)
      example.run
    ensure
      ActiveRecord::Base.logger = old
    end
  end

  Capybara.default_driver = Capybara.javascript_driver = :poltergeist
end
