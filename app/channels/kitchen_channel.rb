class KitchenChannel < ApplicationCable::Channel

  def subscribed
    stream_from "kitchens_#{current_user.organization.cnpj}"
  end

  def unsubscribed; end
end
