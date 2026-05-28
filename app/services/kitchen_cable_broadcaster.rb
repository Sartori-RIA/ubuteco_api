# frozen_string_literal: true

# Delivers kitchen queue updates via Action Cable pubsub (AnyCable forwards to anycable-go).
#
# With AnyCable, WebSocket clients connect to anycable-go, not Puma — only
# ActionCable.server.broadcast is used (no direct transmit to local connections).
class KitchenCableBroadcaster
  def self.deliver(organization_id:, message:)
    stream = "kitchens_#{organization_id}"
    payload = message.deep_stringify_keys

    ActionCable.server.broadcast(stream, payload)

    delivered = 0
    unless anycable_mode?
      ActionCable.server.connections.each do |connection|
        delivered += deliver_to_connection(connection, stream, payload)
      end
    end

    adapter = ActionCable.server.config.cable.fetch('adapter', 'unknown')
    Rails.logger.info(
      "[KitchenCable] stream=#{stream} adapter=#{adapter} anycable=#{anycable_mode?} " \
      "pubsub_broadcast=ok direct_transmits=#{delivered} " \
      "open_connections=#{ActionCable.server.connections.size}"
    )
  end

  def self.anycable_mode?
    defined?(AnyCable::Rails) && AnyCable::Rails.enabled?
  end
  private_class_method :anycable_mode?

  def self.deliver_to_connection(connection, stream, message)
    count = 0
    connection.subscriptions.send(:subscriptions).each_value do |channel|
      next unless channel.is_a?(KitchenChannel)

      streams = channel.send(:streams)
      next unless streams.key?(stream)

      channel.transmit(message)
      count += 1
    end
    count
  end
end
