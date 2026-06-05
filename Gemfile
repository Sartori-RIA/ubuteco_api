# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.1'

gem 'aasm', '~> 5.5'
gem 'bootsnap', '~> 1.23', require: false
gem 'cancancan', '~> 3.6', '>= 3.6.1'
gem 'devise', '~> 5.0', '>= 5.0.4'
gem 'devise-argon2', '~> 2.0', '>= 2.0.4'
gem 'devise-i18n', '~> 1.16'
gem 'devise-jwt', '~> 0.13.0'
gem 'dotenv-rails', '~> 3.2'
gem 'jbuilder', '~> 2.14', '>= 2.14.1'
gem 'listen', '~> 3.10'
gem 'loofah', '~> 2.25', '>= 2.25.1'
gem 'mini_magick', '~> 5.3', '>= 5.3.1'
gem 'image_processing', '~> 1.13'
gem 'aws-sdk-s3', '~> 1', require: false
gem 'money-rails', '~> 3.0'
gem "opensearch-ruby", "~> 2.1.0"
gem 'pagy', '~> 43.2', '>= 43.2.9'
gem 'paranoia', '~> 3.1'
gem 'pg', '~> 1.6', '>= 1.6.3'
gem 'puma', '~> 7.2'
gem 'rack', '~> 3.2', '>= 3.2.6'
gem 'rack-attack', '~> 6.8'
gem 'rack-cors', '~> 3.0'
gem 'rails', '~> 8.1', '>= 8.1.3'
gem 'rails-i18n', '~> 8.1'
gem 'redis', '~> 5.4', '>= 5.4.1'
gem "searchkick", "6.0.3"
gem 'sidekiq', '~> 8.1'
gem 'rswag', '~> 2.13'

group :development do
  gem 'bullet'
end

group :development, :test do
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'byebug', platforms: %i[mri windows]
  gem 'factory_bot_rails', '~> 6.5', '>= 6.5.1'
  gem 'faker', '~> 3.6'
  gem 'fuubar', '~> 2.5', '>= 2.5.1'
  gem 'reek'
  gem 'rspec', '~> 3.13', '>= 3.13.2'
  gem 'rspec-json_expectations'
  gem 'rspec-rails', '~> 8.0', '>= 8.0.2'
  gem 'rubocop'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'rubycritic'
end

group :test do
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'simplecov-cobertura'
  gem 'rspec-sidekiq'
  gem 'database_cleaner-active_record'
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

gem "anycable-rails", "~> 1.6"
