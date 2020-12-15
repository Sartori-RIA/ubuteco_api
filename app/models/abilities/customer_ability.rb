# frozen_string_literal: true

module Abilities
  class CustomerAbility < Ability
    def initialize(user, params, controller_name)
      super
      can :manage, User, id: user.id
      can %i[search], Beer
      can %i[read search], Dish
      can %i[read search], Drink
      can %i[read search], Food
      can %i[read search], Maker
      can %i[read search], Order
      can %i[read search], Table
      can %i[read search], Wine
    end
  end
end
