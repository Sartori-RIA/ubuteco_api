# frozen_string_literal: true

module Abilities
  class CashRegisterAbility < Abilities::BaseAbility
    def initialize(user:, params:, controller_name:)
      super()
      can :manage, User, id: user.id
      can %i[manage search], Order, organization_id: user.organization_id
      can :manage, OrderItem, order: {
        id: params[:order_id],
        organization_id: user.organization_id
      }
      can %i[read search], Drink, organization_id: user.organization_id
      can %i[read search], Food, organization_id: user.organization_id
      cannot %i[update destroy], Order, organization_id: user.organization_id, status: 'payed'
      cannot %i[create update destroy], OrderItem, order: {
        id: params[:order_id],
        organization_id: user.organization_id, status: 'payed'
      }
      if controller_name == 'Api::Kitchens'
        can :read, OrderItem,
            item_type: :Dish,
            created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day,
            order: { organization_id: user.organization_id }
      end
    end
  end
end
