# frozen_string_literal: true

module Abilities
  class AdminAbility < Abilities::BaseAbility
    def initialize(user:, params:)
      super()
      can :manage, User, organization_id: user.organization_id
      can :read, Theme, organization_id: user.organization_id
      can :update, Theme, organization: { user_id: user.id }
      can :read, Organization, id: user.organization_id
      can :manage, Organization, user_id: user.id
      products_permissions(user)
      orders_permissions(user, params)
    end

    def products_permissions(user)
      can %i[manage search], Beer, organization_id: user.organization_id
      can %i[manage search], Dish, organization_id: user.organization_id
      can %i[manage], DishIngredient
      can %i[manage search], Drink, organization_id: user.organization_id
      can %i[manage search], Food, organization_id: user.organization_id
      can %i[manage search], Maker, organization_id: user.organization_id
      can %i[manage search], Table, organization_id: user.organization_id
      can %i[manage search], Wine, organization_id: user.organization_id
      cannot %i[edit create destroy], BeerStyle
      cannot %i[edit create destroy], WineStyle
    end

    def orders_permissions(user, params)
      can :create, Order
      can %i[read search], Order, organization_id: user.organization_id
      can :manage, OrderItem,
          order_id: params[:order_id],
          order: { organization_id: user.organization_id }
      can %i[update destroy], Order,
          organization_id: user.organization_id,
          status: :open
      can %i[update destroy], OrderItem,
          order_id: params[:order_id],
          order: { organization_id: user.organization_id, status: :open }
    end
  end
end
