# frozen_string_literal: true

module Abilities
  class SuperAdminAbility < Abilities::BaseAbility
    PLATFORM_CONTROLLERS = [
      'Api::V1::Platform::Organizations',
      'Api::V1::Platform::Organizations::Users'
    ].freeze

    def initialize(user:, params:, controller_name:)
      super()
      can_manage_self(user:, controller_name:)
      customer_search(controller_name:)

      if platform_controller?(controller_name)
        platform_permissions
        organization_users_support(organization_id: params[:organization_id], controller_name:)
      else
        global_resource_permissions
        catalog_read_permissions
      end
    end

    def platform_controller?(controller_name)
      PLATFORM_CONTROLLERS.include?(controller_name)
    end

    def platform_permissions
      can :manage, Organization
      can :manage, Role
      can %i[manage style_available?], BeerStyle
      can %i[manage style_available?], WineStyle
    end

    def global_resource_permissions
      can :manage, Role
      can %i[manage style_available?], BeerStyle
      can %i[manage style_available?], WineStyle
      can :read, Order
    end

    def organization_users_support(organization_id:, controller_name:)
      return unless controller_name == 'Api::V1::Platform::Organizations::Users'
      return if organization_id.blank?

      can :manage, User, organization_id: organization_id
    end

    def catalog_read_permissions
      can :read, Beer
      can :read, Dish
      can :read, DishIngredient
      can :read, Drink
      can :read, Food
      can :read, Maker
      can :read, Table
      can :read, Wine
    end
  end
end
