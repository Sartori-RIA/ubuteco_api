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
      can :create, Order
      can %i[read search], Order, user_id: user.id
      can %i[update destroy], Order, user_id: user.id, status: :open
      can %i[read search], OrderItem, order: { user_id: user.id }
      can :create, OrderItem, order: { user_id: user.id, status: :open }
      can %i[update destroy], OrderItem, order_id: params[:order_id], order: { user_id: user.id, status: :open }
    end
  end
end
