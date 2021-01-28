# frozen_string_literal: true

module Abilities
  class AdminAbility < Abilities::BaseAbility
    def initialize(user:, params:)
      super()
      can :manage, User, organization_id: user.organization_id
      can %i[read], Theme, organization_id: user.organization_id
      can %i[update], Theme, organization: { user_id: user.id }
      can %i[read], Organization, id: user.organization_id
      can :manage, Organization, user_id: user.id
      products_permissions(user)
      orders_permissions(user: user, params: params)
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

    def orders_permissions(user:, params:)
      can %i[create], Order
      can %i[read search], Order, organization_id: user.organization_id
      can %i[update destroy], Order, organization_id: user.organization_id, status: :open
      can %i[create read search], OrderItem
      can %i[read search], OrderItem, order: { id: params[:id], organization_id: user.organization_id }
      can %i[create update destroy], OrderItem, order: { id: params[:id], organization_id: user.organization_id, status: :open }
    end
  end
end
