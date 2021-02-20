# frozen_string_literal: true

# noinspection ALL
module Abilities
  class BaseAbility
    include CanCan::Ability

    def initialize
      alias_action :index, :show, :search, to: :read
      can :read, BeerStyle
      can :read, WineStyle
      can :email_available?, User
      can :cnpj_available?, Organization
      can :phone_available?, Organization
    end

    def organization_order(user:, params:)
      can :create, Order
      can :read, Order, organization_id: user.organization_id
      can %i[update destroy], Order, organization_id: user.organization_id, status: :open
      can :read, OrderItem, order: { id: params[:order_id], organization_id: user.organization_id }
      can %i[create update destroy], OrderItem, order: { organization_id: user.organization_id, status: :open }
    end

    def kitchens_namespace(controller_name:, user:)
      return unless controller_name == 'Api::Kitchens'

      can :read, OrderItem,
          item_type: 'Dish',
          created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day,
          order: { organization_id: user.organization_id }
      can :update, OrderItem,
          order: {
            organization_id: user.organization_id,
            status: :open
          }
    end
  end
end
