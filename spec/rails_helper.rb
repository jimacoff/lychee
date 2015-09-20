ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require 'factory_girl_rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'fakefs/spec_helpers'

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
  config.use_transactional_fixtures = false

  # Use FactoryGirl
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  # Supply a site scope when requested
  config.include SpecSite, site_scoped: true
  config.around(:example, :site_scoped) { |e| with_spec_site { e.run } }

  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
  config.around do |example|
    strategies = Hash.new(:transaction).merge(feature: :truncation)
    DatabaseCleaner.strategy = strategies[example.metadata[:type]]
    DatabaseCleaner.cleaning { example.run }
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

FakeFS::FileSystem.clone(Rails.root.join('app'))
FakeFS::FileSystem.clone(Rails.root.join('config'))
FakeFS::FileSystem.clone(Rails.root.join('lib'))
FakeFS::FileSystem.clone(Rails.root.join('public'))
FakeFS::FileSystem.clone(Rails.root.join('spec'))
