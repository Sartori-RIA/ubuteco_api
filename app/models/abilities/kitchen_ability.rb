# frozen_string_literal: true

module Abilities
  class KitchenAbility < Abilities::BaseAbility
    def initialize(user:, controller_name:)
      super()
      can_manage_self(user: user, controller_name: controller_name)
      theme(organization_id: user.organization_id)
      kitchens_namespace controller_name: controller_name, user: user
    end
  end
end
