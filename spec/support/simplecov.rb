# frozen_string_literal: true

if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  require 'simplecov-cobertura'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CoberturaFormatter
  ]

  SimpleCov.start :rails do
    enable_coverage :branch
    add_group 'Abilities', 'app/models/abilities'
    add_group 'Services', 'app/services'
    command_name 'rspec'
  end
end