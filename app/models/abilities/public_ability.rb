# frozen_string_literal: true

module Abilities
  class PublicAbility
    include CanCan::Ability

    def initialize(user, params, controller_name)
      can %i[read search], BeerStyle
      can %i[read search], WineStyle
    end
  end
end
