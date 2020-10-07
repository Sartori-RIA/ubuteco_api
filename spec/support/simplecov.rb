if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start :rails
end
