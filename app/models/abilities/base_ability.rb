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
      can :phone_available?, Organization
    end

    def organization_order(user:, params:)
      can :create, Order
      can :read, Order, organization_id: user.organization_id
      can %i[update destroy], Order, organization_id: user.organization_id, status: :open
      can :read, OrderItem, order: { organization_id: user.organization_id }
      can %i[create update destroy], OrderItem, order: { organization_id: user.organization_id, status: :open }
    end

    def can_manage_self(user:, controller_name:)
      can :manage, User, id: user.id unless controller_name == 'Api::V1::Customers'
    end

    def can_manage_organization_users(organization_id:, controller_name:)
      case controller_name
      when 'Api::V1::Organizations::Users'
        can :manage, User, organization_id: organization_id if organization_id.present?
      when 'Api::V1::Users'
        can :manage, User, organization_id: organization_id if organization_id.present?
      end
    end

    def customer_search(controller_name:)
      can %i[read search], User, role: { name: 'CUSTOMER' } if controller_name == 'Api::V1::Customers'
    end

    def kitchens_namespace(controller_name:, user:)
      return unless controller_name == 'Api::V1::Kitchens'

      can :read, OrderItem,
          item_type: 'Dish',
          order: { organization_id: user.organization_id, status: :open }
      can :update, OrderItem,
          order: {
            organization_id: user.organization_id,
            status: :open
          }
    end

    def organization_operational_control(user:, controller_name:)
      return unless controller_name == 'Api::V1::Organizations'

      can %i[read update], Organization, id: user.organization_id
    end
  end
end
