FactoryTrace.configure do |config|
  config.enabled = true

  config.path = 'spec/factory_trace.txt'

  config.color = true

  config.mode = :full

  config.trace_definition = true
end
