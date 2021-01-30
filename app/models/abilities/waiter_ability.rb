# frozen_string_literal: true

module Abilities
  class WaiterAbility < Abilities::BaseAbility
    def initialize(user:, params:)
      super()
      can :manage, User, id: user.id
      products_permissions(user)
      orders_permissions(user, params)
    end

    def products_permissions(user)
      can %i[read search], Table, organization_id: user.organization_id
      can %i[read search], Wine, organization_id: user.organization_id
      can %i[read search], Beer, organization_id: user.organization_id
      can %i[read search], Dish, organization_id: user.organization_id
      can %i[read search], Drink, organization_id: user.organization_id
      can %i[read search], Food, organization_id: user.organization_id
      can %i[read search], Maker, organization_id: user.organization_id
    end

    def orders_permissions(user, params)
      can :create, Order
      can %i[read search], Order, organization_id: user.organization_id
      can %i[update destroy], Order, organization_id: user.organization_id, status: :open
      can %i[read search], OrderItem, order: { id: params[:order_id], organization_id: user.organization_id }
      can %i[create update destroy], OrderItem, order: { organization_id: user.organization_id, status: :open }
    end
  end
end
