# frozen_string_literal: true

module Abilities
  class SuperAdminAbility < Abilities::BaseAbility
    def initialize(user:, params:)
      super()
      can :manage, Organization
      can :manage, Role
      can %i[update read], Theme, organization_id: user.organization_id
      can :manage, User
      can :manage, Wine
      can :manage, WineStyle
      products_permissions
      orders_permissions(params: params)
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

    def orders_permissions(params:)
      can :create, Order
      can %i[read search], Order
      can %i[update destroy], Order, status: :open
      can %i[read search], OrderItem, order: { id: params[:id] }
      can %i[create update destroy], OrderItem, order: { id: params[:id], status: :open }
    end
  end
end
