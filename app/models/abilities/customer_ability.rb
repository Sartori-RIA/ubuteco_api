# frozen_string_literal: true

module Abilities
  class CustomerAbility < Abilities::BaseAbility
    def initialize(user:, params:, controller_name:)
      super()
      can_manage_self(user:, controller_name:)
      products_permissions(user:, params:)
      order_permissions(user:, params:)
    end

    def products_permissions(user:, params:)
      organization_id = user.organization_id.presence || params[:organization_id]
      return if organization_id.blank?

      product_scope = { organization_id: organization_id }
      can :read, Beer, product_scope
      can :read, Dish, product_scope
      can :read, Drink, product_scope
      can :read, Food, product_scope
      can :read, Maker, product_scope
      can :read, Table, product_scope
      can :read, Wine, product_scope
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
