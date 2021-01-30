# frozen_string_literal: true

module Abilities
  class CashRegisterAbility < Abilities::BaseAbility
    def initialize(user:, params:, controller_name:)
      super()
      can %i[read update], User, id: user.id
      can %i[read search], User, role: { name: 'CUSTOMER' }
      products_permissions(user)
      orders_permissions(user: user, params: params, controller_name: controller_name)
    end

    def products_permissions(user)
      can %i[read search], Dish, organization_id: user.organization_id
      can %i[read search], Beer, organization_id: user.organization_id
      can %i[read search], Wine, organization_id: user.organization_id
      can %i[read search], Drink, organization_id: user.organization_id
      can %i[read search], Food, organization_id: user.organization_id
    end

    def orders_permissions(user:, params:, controller_name:)
      can :create, Order
      can %i[read search], Order, organization_id: user.organization_id
      can %i[update destroy], Order, organization_id: user.organization_id, status: :open
      can %i[read search], OrderItem, order: { id: params[:order_id], organization_id: user.organization_id }
      can :create, OrderItem, order: { organization_id: user.organization_id, status: :open }
      can %i[update destroy], OrderItem, order: { id: params[:order_id], organization_id: user.organization_id, status: :open }
      if controller_name == 'Api::Kitchens'
        can :read, OrderItem,
            item_type: :Dish,
            created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day,
            order: {
              organization_id: user.organization_id
            }
      end
    end
  end
end
