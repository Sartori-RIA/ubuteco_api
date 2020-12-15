# frozen_string_literal: true

module Abilities
  class CashRegisterAbility < Ability
    def initialize(user, params, controller_name)
      super
      can :manage, User, id: user.organization_id
      can %i[manage search], Order, organization_id: user.organization_id
      cannot :update, Order, organization_id: user.organization_id, status: 'payed'
      can :manage, OrderItem, order_id: params[:order_id], order: { organization_id: user.organization_id }
      cannot :manage, OrderItem, order_id: params[:order_id], order: { organization_id: user.organization_id, status: 'payed'}
      can %i[read search], Drink, organization_id: user.organization_id
      can %i[read search], Food, organization_id: user.organization_id
    end
  end
end
