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
      can :read, Beer
      can :read, Dish
      can :read, Drink
      can :read, Food
      can :read, Maker
      can :read, Table
      can :read, Wine
    end

    def order_permissions(user:, params:)
      can :create, Order
      can :read, Order, user_id: user.id
      can %i[update destroy], Order, user_id: user.id, status: :open
      can :read, OrderItem, order: { user_id: user.id }
      can :create, OrderItem, order: { user_id: user.id, status: :open }
      can %i[update destroy], OrderItem, order_id: params[:order_id], order: { user_id: user.id, status: :open }
    end
  end
end
