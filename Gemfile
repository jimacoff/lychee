source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'pg', '~> 0.18'
gem 'postgres_ext', '~> 2.3'

# TODO: required for https://github.com/RubyMoney/money-rails/issues/263
# Change to release greater than 1.2.0 when available
gem 'money-rails', git: 'https://github.com/RubyMoney/money-rails.git'
gem 'stringex', '~> 2.5'

gem 'paper_trail', '~>4.0.0.beta2'

gem 'valhammer', git: 'https://github.com/ausaccessfed/valhammer.git',
                 branch: 'develop'

gem 'abstract_method'

# Web
gem 'uglifier', '~> 2.5.3'
gem 'therubyracer',  platforms: :ruby
gem 'turbolinks'

# JSON
gem 'jbuilder', '~> 2.2.6'
gem 'json-schema', '~> 2.5.0'

# Security
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Deployment
gem 'unicorn', '~> 4.8.3'

group :development, :test do
  gem 'rspec-rails', '~> 3.2'
  gem 'shoulda-matchers'
  gem 'shoulda-callback-matchers'
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'rubocop'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rubocop'
  gem 'guard-rspec'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'brakeman'
  gem 'temping'
  gem 'database_cleaner'
end
