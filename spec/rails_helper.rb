ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require 'factory_girl_rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
ActiveRecord::Migration.maintain_test_schema!

spec_site = FactoryGirl.create(:site)

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  # Use FactoryGirl
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  # Supply a site scope when requested
  config.around(:example, :site_scoped) do |example|
    Site.current = spec_site
    example.run
    Site.current = nil
  end
end
