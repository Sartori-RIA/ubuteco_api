# frozen_string_literal: true

module Abilities
  class AdminAbility < Abilities::BaseAbility
    def initialize(user:, params:, controller_name:)
      super()
      can %i[update read], Theme, organization_id: user.organization_id
      can :manage, Organization, id: user.organization_id
      can :read, Role
      can_manage_organization_users(organization_id: user.organization_id, controller_name: controller_name)
      can_manage_self(user: user, controller_name: controller_name)
      customer_search(controller_name: controller_name)
      products_permissions(user)
      orders_permissions(user: user, params: params, controller_name: controller_name)
    end

    def products_permissions(user)
      can :manage, Beer, organization_id: user.organization_id
      can :manage, Dish, organization_id: user.organization_id
      can :manage, DishIngredient
      can :manage, Drink, organization_id: user.organization_id
      can :manage, Food, organization_id: user.organization_id
      can :manage, Maker, organization_id: user.organization_id
      can :manage, Table, organization_id: user.organization_id
      can :manage, Wine, organization_id: user.organization_id
      cannot %i[edit create destroy], BeerStyle
      cannot %i[edit create destroy], WineStyle
    end

    def orders_permissions(user:, params:, controller_name:)
      organization_order user: user, params: params
      kitchens_namespace controller_name: controller_name, user: user
    end
  end
end
