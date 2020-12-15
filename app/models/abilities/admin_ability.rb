# frozen_string_literal: true

module Abilities
  class AdminAbility < Ability
    def initialize(user, params, controller_name)
      super
      can :manage, User, organization_id: user.organization_id
      can :read, Theme, organization_id: user.organization_id
      can :update, Theme, organization: { user_id: user.id }
      can :read, Organization, id: user.organization_id
      can :manage, Organization, user_id: user.id

      can %i[manage search], Beer, organization_id: user.organization_id
      can %i[manage search], Dish, organization_id: user.organization_id
      can %i[manage], DishIngredient
      can %i[manage search], Drink, organization_id: user.organization_id
      can %i[manage search], Food, organization_id: user.organization_id
      can %i[manage search], Maker, organization_id: user.organization_id
      can %i[manage search], Order, organization_id: user.organization_id
      cannot :update, Order, organization_id: user.organization_id, status: 'payed'
      can :manage, OrderItem,
          order_id: params[:order_id],
          order: {
            organization_id: user.organization_id
          }
      cannot :manage, OrderItem,
             order_id: params[:order_id],
             order: {
               organization_id: user.organization_id, status: 'payed'
             }
      can %i[manage search], Table, organization_id: user.organization_id
      can %i[manage search], Wine, organization_id: user.organization_id
    end
  end
end
