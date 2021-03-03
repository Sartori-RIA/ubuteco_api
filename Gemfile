# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'api-pagination'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bugsnag', '~> 6.19'
gem 'cancancan'
gem 'carrierwave', '~> 2.0'
gem 'carrierwave-i18n'
gem 'cpf_cnpj'
gem 'devise'
gem 'devise-argon2'
gem 'devise-encryptable'
gem 'devise-i18n'
gem 'devise-jwt', '~> 0.7.0'
gem 'dry-configurable', '0.9.0'
gem 'figaro'
gem 'fog-aws'
gem 'kaminari'
gem 'listen', '~> 3.2'
gem 'mini_magick'
gem 'money-rails', '~>1.13'
gem 'paranoia', '~> 2.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pg_search'
gem 'puma', '~> 4.1'
gem 'rack-attack'
gem 'rack-cors'
gem 'rails', '~> 6.0.3', '>= 6.0.3.3'
gem 'rails-i18n'
gem 'redis', '~> 3.3', '>= 3.3.1'
gem 'rubocop-rails'
gem 'validators'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'fuubar'
  gem 'rspec'
  gem 'rspec-json_expectations'
  gem 'rspec-rails'
end

group :development, :test do
  # Recommend to lock the mutant gems current major version, via '~> # 0.9.x'
  gem 'mutant-rspec', '~> 0.10.20'
  source 'https://oss:wKXUfu1alkPFjjIkCqNag7ya5NcXJxcd@gem.mutant.dev' do
    gem 'mutant-license', require: false
  end
end

group :development do
  gem 'mailcatcher'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', '~>0.17.1', require: false
  gem 'simplecov-console', require: false
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
