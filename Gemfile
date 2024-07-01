# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'bugsnag', '~> 6.26', '>= 6.26.4'
gem 'cancancan', '~> 3.5'
gem 'carrierwave', '~> 3.0', '>= 3.0.7'
gem 'carrierwave-i18n', '~> 3.0'
gem 'devise', '~> 4.9', '>= 4.9.4'
gem 'devise-argon2', '~> 2.0', '>= 2.0.1'
gem 'devise-i18n', '~> 1.12'
gem 'devise-jwt', '~> 0.11.0'
gem 'dry-configurable', '~> 1.1'
gem 'figaro', '~> 1.2'
gem 'fog-aws', '~> 3.22'
gem 'jbuilder', '~> 2.11', '>= 2.11.5'
gem 'listen', '~> 3.9'
gem 'loofah', '~> 2.22'
gem 'mini_magick', '~> 4.12'
gem 'money-rails', '~> 1.15'
gem 'pagy', '~> 8.4'
gem 'paranoia', '~> 2.6', '>= 2.6.3'
gem 'pg'
gem 'pg_search', '~> 2.3', '>= 2.3.6'
gem 'puma', '~> 6.4', '>= 6.4.2'
gem 'rack', '~> 3.0', '>= 3.0.10'
gem 'rack-attack', '~> 6.7'
gem 'rack-cors', '~> 2.0', '>= 2.0.2'
gem 'rails', '~> 7.1.3', '>= 7.1.3.2'
gem 'rails-i18n', '~> 7.0', '>= 7.0.9'
gem 'redis', '~> 5.2'
gem 'rswag', '~> 2.13'
gem 'rubocop-rails', '~> 2.24', '>= 2.24.1'
gem 'validators', '~> 3.4', '>= 3.4.2'
gem 'dotenv-rails'

group :development, :test do
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.4', '>= 6.4.3'
  gem 'faker', '~> 3.3', '>= 3.3.1'
  gem 'fuubar', '~> 2.5', '>= 2.5.1'
  gem 'parallel_tests'
  gem 'reek'
  gem 'rspec', '~> 3.13'
  gem 'rspec-json_expectations'
  gem 'rspec-rails', '~> 6.1', '>= 6.1.2'
  gem 'rubocop-rspec'
  gem 'rubycritic'
end

group :development do
  gem 'rubocop', require: false
  # gem 'spring'
  # gem 'spring-watcher-listen'
end

group :test do
  gem 'database_cleaner'
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-console'
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
