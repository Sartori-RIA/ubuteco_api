# frozen_string_literal: true

class KitchenChannel < ApplicationCable::Channel
  def subscribed
    org_id = current_user.organization_id
    reject unless org_id

    stream_from "kitchens_#{org_id}"
  end

  def unsubscribed; end
end
