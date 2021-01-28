# frozen_string_literal: true

module Abilities
  class SuperAdminAbility < Abilities::BaseAbility
    def initialize(user:, params:)
      super()
      can :manage, Organization
      can :manage, Role
      can :read, Theme, organization_id: user.organization_id
      can :update, Theme, organization: { user_id: user.id }
      can :manage, User
      can :manage, Wine
      can :manage, WineStyle
      products_permissions
      orders_permissions(user: user, params: params)
    end

    def products_permissions
      can :manage, Beer
      can :manage, BeerStyle
      can :manage, Dish
      can :manage, DishIngredient
      can :manage, Drink
      can :manage, Food
      can :manage, Maker
      can :manage, Table
    end

    def orders_permissions(user:, params:)
      can :create, Order
      can %i[read search], Order, organization_id: user.organization_id
      can %i[read search], OrderItem,
          order: {
            id: params[:id],
            organization_id: user.organization_id
          }
      can :create, OrderItem,
          order: {
            id: params[:id],
            organization_id: user.organization_id
          }
      can %i[update destroy], Order, organization_id: user.organization_id
      can %i[update destroy], OrderItem,
          order: {
            id: params[:id],
            organization_id: user.organization_id
          }
    end
  end
end
