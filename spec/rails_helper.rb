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

spec_site = spec_tenant = nil

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  # Use FactoryGirl
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    spec_site = FactoryGirl.create(:site)
    spec_tenant = FactoryGirl.create(:tenant, site: spec_site)

    ActionController::TestRequest::DEFAULT_ENV
      .merge!('HTTP_HOST' => spec_tenant.identifier)
  end

  # Supply a site scope when requested
  config.around(:example, :site_scoped) do |example|
    Site.current = spec_site
    example.run
    Site.current = nil
  end

  config.after(:suite) do
    spec_site.delete if spec_site
  end

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
