if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  require 'simplecov/parallel'
  SimpleCov::Parallel.activate
  SimpleCov.start :rails do
    add_group "Uploaders", "app/uploaders"
    add_group "Abilities", "app/models/abilities"
  end
end
