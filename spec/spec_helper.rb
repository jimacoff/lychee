require 'simplecov'
require 'factory_girl_rails'

SimpleCov.start do
  add_filter '/spec'
end

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.default_formatter = 'doc' unless config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.include FactoryGirl::Syntax::Methods

  config.alias_it_should_behave_like_to :has_context, 'has context'

  # config.profile_examples = 10
end

RSpec::Matchers.define_negated_matcher :exclude, :include
RSpec::Matchers.define_negated_matcher :not_change, :change
