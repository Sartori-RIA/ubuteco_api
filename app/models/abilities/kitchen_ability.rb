# frozen_string_literal: true

module Abilities
  class KitchenAbility < Abilities::BaseAbility
    def initialize(user:, controller_name:)
      super()
      can :manage, User, id: user.id
      kitchens_namespace controller_name: controller_name, user: user
    end
  end
end
