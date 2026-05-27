# frozen_string_literal: true

module Abilities
  class SuperAdminAbility < Abilities::BaseAbility
    def initialize(user:, params:, controller_name:)
      super()
      platform_permissions
      can_manage_self(user:, controller_name:)
      organization_users_support(organization_id: params[:organization_id], controller_name:)
      operational_read_permissions
      customer_search(controller_name:)
    end

    def platform_permissions
      can :manage, Organization
      can :manage, Role
      can %i[manage style_available?], BeerStyle
      can %i[manage style_available?], WineStyle
    end

    def organization_users_support(organization_id:, controller_name:)
      return unless controller_name == 'Api::V1::Organizations::Users'
      return if organization_id.blank?

      can :manage, User, organization_id: organization_id
    end

    def operational_read_permissions
      can :read, Beer
      can :read, Dish
      can :read, DishIngredient
      can :read, Drink
      can :read, Food
      can :read, Maker
      can :read, Table
      can :read, Wine
      can :read, Order
      can :read, OrderItem
      can :read, User
      can :read, Theme
    end
  end
end
