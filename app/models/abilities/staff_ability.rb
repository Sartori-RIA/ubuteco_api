# frozen_string_literal: true

module Abilities
  class StaffAbility < Ability
    def initialize(user, params, controller_name)
      super
      can :manage, BeerStyle
      can :manage, WineStyle
      can :manage, User
    end
  end
end
