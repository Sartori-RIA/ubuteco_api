# frozen_string_literal: true

module Abilities
  class PublicAbility < Ability
    def initialize(user, params, controller_name)
      super
      can %i[read search], BeerStyle
      can %i[read search], WineStyle
    end
  end
end
