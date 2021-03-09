# frozen_string_literal: true

module Abilities
  class SuperAdminAbility < Abilities::BaseAbility
    def initialize(user:, params:)
      super()
      can :manage, Organization
      can :manage, Role
      can %i[update read], Theme, organization_id: user.organization_id
      can :manage, User, id: user.id if controller_name == 'Api::Users'
      can :manage, User, organization_id: params[:organization_id] if controller_name == 'Api::Organizations::Users'
      customer_search(controller_name: controller_name)
      products_permissions
      orders_permissions(params: params)
    end

    def products_permissions
      can :manage, Beer
      can %i[manage style_available?], BeerStyle
      can :manage, Dish
      can :manage, DishIngredient
      can :manage, Drink
      can :manage, Food
      can :manage, Maker
      can :manage, Table
      can :manage, Wine
      can %i[manage style_available?], WineStyle
    end

    def orders_permissions(params:)
      can :create, Order
      can :read, Order
      can %i[update destroy], Order, status: :open
      can :read, OrderItem, order_id: params[:id]
      can %i[create update destroy], OrderItem, order: { id: params[:id], status: :open }
    end
  end
end
