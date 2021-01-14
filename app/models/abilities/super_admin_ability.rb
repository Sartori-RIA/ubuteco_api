# frozen_string_literal: true

module Abilities
  class SuperAdminAbility < Abilities::BaseAbility
    def initialize(user:)
      super()
      can %i[manage search], Beer
      can %i[manage search], BeerStyle
      can %i[manage search], Dish
      can %i[manage search], DishIngredient
      can %i[manage search], Drink
      can %i[manage search], Food
      can %i[manage search], Maker
      can %i[manage search], Order
      can %i[manage search], OrderItem
      can %i[manage search], Organization
      can %i[manage search], Role
      can %i[manage search], Table
      can :read, Theme, organization_id: user.organization_id
      can :update, Theme, organization: { user_id: user.id }
      can %i[manage search], User
      can %i[manage search], Wine
      can %i[manage search], WineStyle
      cannot %i[update destroy], Order, status: 'payed'
      cannot %i[update destroy create], OrderItem, order: { status: 'payed' }
    end
  end
end
