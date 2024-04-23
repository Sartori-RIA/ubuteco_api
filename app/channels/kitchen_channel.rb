# frozen_string_literal: true

class KitchenChannel < ApplicationCable::Channel
  def subscribed
    stream_from "kitchens_#{current_user.organization.id}"
  end

  def unsubscribed; end
end
