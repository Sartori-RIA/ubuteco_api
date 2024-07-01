# frozen_string_literal: true

module Abilities
  class WaiterAbility < Abilities::BaseAbility
    def initialize(user:, params:, controller_name:)
      super()
      can_manage_self(user:, controller_name:)
      customer_search(controller_name:)
      theme(organization_id: user.organization_id)
      products_permissions(user)
      orders_permissions(user:, params:, controller_name:)
    end

    def products_permissions(user)
      can :read, Table, organization_id: user.organization_id
      can :read, Wine, organization_id: user.organization_id
      can :read, Beer, organization_id: user.organization_id
      can :read, Dish, organization_id: user.organization_id
      can :read, Drink, organization_id: user.organization_id
      can :read, Food, organization_id: user.organization_id
      can :read, Maker, organization_id: user.organization_id
    end

    def orders_permissions(user:, params:, controller_name:)
      organization_order(user:, params:)
      kitchens_namespace controller_name:, user:
    end
  end
end
