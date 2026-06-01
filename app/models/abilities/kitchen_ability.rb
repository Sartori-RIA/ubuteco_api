# frozen_string_literal: true

module Abilities
  class KitchenAbility < Abilities::BaseAbility
    def initialize(user:, controller_name:)
      super()
      can_manage_self(user:, controller_name:)
      organization_operational_control(user:, controller_name:)
      kitchens_namespace(controller_name:, user:)
    end
  end
end
