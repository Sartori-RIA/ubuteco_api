# frozen_string_literal: true

if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start :rails do
    add_group 'Uploaders', 'app/uploaders'
    add_group 'Abilities', 'app/models/abilities'
  end
end
