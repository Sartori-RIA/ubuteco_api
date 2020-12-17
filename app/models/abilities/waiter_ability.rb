# frozen_string_literal: true

module Abilities
  class WaiterAbility
    include CanCan::Ability

    def initialize(user, params, controller_name)
      can :manage, User, id: user.id
      can %i[read search], Table, organization_id: user.organization_id
      can %i[read search], Wine, organization_id: user.organization_id
      can %i[read search], Beer, organization_id: user.organization_id
      can %i[read search], Dish, organization_id: user.organization_id
      can %i[read search], Drink, organization_id: user.organization_id
      can %i[read search], Food, organization_id: user.organization_id
      can %i[read search], Maker, organization_id: user.organization_id
      can %i[read search], Order, organization_id: user.organization_id
    end
  end
end
