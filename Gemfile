# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'api-pagination', '~> 4.8', '>= 4.8.2'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'bugsnag', '~> 6.19'
gem 'cancancan', '~> 3.2', '>= 3.2.2'
gem 'carrierwave', '~> 2.2'
gem 'carrierwave-i18n', '~> 0.2.0'
gem 'cpf_cnpj', '~> 0.5.0'
gem 'devise', '~> 4.7', '>= 4.7.3'
gem 'devise-argon2', '~> 1.1'
gem 'devise-encryptable', '~> 0.2.0'
gem 'devise-i18n', '~> 1.9', '>= 1.9.3'
gem 'devise-jwt', '~> 0.8.1'
gem 'dry-configurable', '0.12.1'
gem 'figaro', '~> 1.2'
gem 'fog-aws', '~> 3.9'
gem 'jbuilder', '~> 2.7'
gem 'kaminari', '~> 1.2', '>= 1.2.1'
gem 'listen', '~> 3.3'
gem 'mini_magick', '~> 4.5', '>= 4.5.1'
gem 'money-rails', '~> 1.14.0'
gem 'paranoia', '~> 2.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pg_search', '~> 2.3', '>= 2.3.5'
gem 'puma', '~> 5.3', '>= 5.3.2'
gem 'rack-attack', '~> 6.5'
gem 'rack-cors', '~> 1.1', '>= 1.1.1'
gem 'rack', '~> 2.2'
gem 'rails', '~> 6.1.3'
gem 'rails-i18n', '~> 6.0'
gem 'redis', '~> 4.0'
gem 'rubocop-rails', '~> 2.9', '>= 2.9.1'
gem 'validators', '~> 3.4', '>= 3.4.1'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'brakeman'
  gem 'factory_bot_rails', '~> 6.1'
  gem 'faker', '~> 2.17'
  gem 'fuubar', '~> 2.5', '>= 2.5.1'
  gem 'mutant-rspec', '~> 0.10.20'
  gem 'reek'
  gem 'rspec', '~> 3.4'
  gem 'rspec-json_expectations'
  gem 'rspec-rails', '~> 5.0.0'
  source 'https://oss:wKXUfu1alkPFjjIkCqNag7ya5NcXJxcd@gem.mutant.dev' do
    gem 'mutant-license', require: false
  end
end

group :development do
  gem 'mailcatcher', '>= 0'
  gem 'rubocop', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers', '~> 4.5.1'
  gem 'simplecov', '~>0.17.1', require: false
  gem 'simplecov-console', require: false
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
