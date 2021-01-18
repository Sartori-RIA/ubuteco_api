# frozen_string_literal: true

module Abilities
  class SuperAdminAbility < Abilities::BaseAbility
    def initialize(user:)
      super()
      can %i[manage search], Organization
      can %i[manage search], Role
      can :read, Theme, organization_id: user.organization_id
      can :update, Theme, organization: { user_id: user.id }
      can %i[manage search], User
      can %i[manage search], Wine
      can %i[manage search], WineStyle
      products_permissions
      orders_permissions
    end

    def products_permissions
      can %i[manage search], Beer
      can %i[manage search], BeerStyle
      can %i[manage search], Dish
      can %i[manage search], DishIngredient
      can %i[manage search], Drink
      can %i[manage search], Food
      can %i[manage search], Maker
      can %i[manage search], Table
    end

    def orders_permissions
      can :create, Order
      can :manage, OrderItem,
          order_id: params[:order_id],
          order: { organization_id: user.organization_id }
      can %i[update destroy], Order,
          organization_id: user.organization_id,
          status: :open
      can %i[edit destroy], OrderItem,
          order_id: params[:order_id],
          order: { organization_id: user.organization_id, status: :open }
    end
  end
end
