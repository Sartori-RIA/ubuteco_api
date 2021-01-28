# frozen_string_literal: true

module Abilities
  class CustomerAbility < Abilities::BaseAbility
    def initialize(user:, params:)
      super()
      can :manage, User, id: user.id
      products_permissions
      order_permissions(user: user, params: params)
    end

    def products_permissions
      can %i[read search], Beer
      can %i[read search], Dish
      can %i[read search], Drink
      can %i[read search], Food
      can %i[read search], Maker
      can %i[read search], Table
      can %i[read search], Wine
    end

    def order_permissions(user:, params:)
      can %i[read search], Order, user_id: user.id
      can %i[read search], OrderItem, order: { user_id: user.id }
      can :manage, Order, user_id: user.id, status: :open
      can :manage, OrderItem, order: { user_id: user.id, status: :open }
      can %i[create], Order
      can :manage, OrderItem, order_id: params[:order_id], order: { organization_id: user.organization_id }
      can %i[update destroy], Order, organization_id: user.organization_id, status: :open
      can %i[edit destroy], OrderItem, order_id: params[:order_id], order: { organization_id: user.organization_id, status: :open }
    end
  end
end
