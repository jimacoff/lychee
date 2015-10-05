ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'factory_girl_rails'

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

module ForceRefresh
  def force_refresh
    old_path = current_path

    visit '/test-store/blank'
    expect(page).to have_text('This page intentionally left blank.')

    visit old_path
  end
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false

  # Use FactoryGirl
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  # Supply a site scope when requested
  config.include SpecSite, site_scoped: true
  config.include ForceRefresh, type: :feature
  config.around(:example, :site_scoped) { |e| with_spec_site { e.run } }

  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }

  config.around do |example|
    strategies = Hash.new(:transaction).merge(feature: :truncation)
    DatabaseCleaner.strategy = strategies[example.metadata[:type]]
    DatabaseCleaner.cleaning { example.run }
  end

  config.after(:suite) do
    paths = Rails.configuration.zepily.publishing.paths
    FileUtils.rm_rf(paths.base)
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
