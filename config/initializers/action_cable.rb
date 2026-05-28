# frozen_string_literal: true

if Rails.env.development?
  ActiveSupport::Notifications.subscribe("broadcast.action_cable") do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Rails.logger.info(
      "[ActionCable] broadcast stream=#{event.payload[:broadcasting]} " \
      "bytes=#{event.payload[:message].to_s.bytesize}"
    )
  end

  ActiveSupport::Notifications.subscribe("transmit.action_cable") do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Rails.logger.info(
      "[ActionCable] transmit to client via=#{event.payload[:via]} " \
      "data=#{event.payload[:data].inspect.truncate(200)}"
    )
  end
end
