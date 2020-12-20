# frozen_string_literal: true

# noinspection ALL
module Abilities
  class BaseAbility
    include CanCan::Ability
    def initialize
      can %i[read search], BeerStyle
      can %i[read search], WineStyle
    end
  end
end
