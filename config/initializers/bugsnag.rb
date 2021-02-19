Bugsnag.configure do |config|
  config.api_key = ENV["BUGSNAG_KEY"]
  config.notify_release_stages = ['production']
  config.discard_classes << "ActiveRecord::RecordNotUnique"
  config.discard_classes << "ActionController::ParameterMissing"
end
