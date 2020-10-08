# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  def initialize(user)
    can :read, BeerStyle
    can :read, Beer
    can :read, Dish
    can :read, Drink
    can :read, Food
    can :read, Maker
    can :read, Table
    can :read, WineStyle
    can :read, Wine

    return if user.blank?

    can :manage, BeerStyle, user: { id: user.id }
    can :manage, Beer, user: { id: user.id }
    can :manage, Dish, user: { id: user.id }
    can :manage, Drink, user: { id: user.id }
    can :manage, Food, user: { id: user.id }
    can :manage, Maker, user: { id: user.id }
    can :manage, Order,
        user: { id: user.id },
        created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    #can :manage, OrderItem, [order: { user: { id: user.id } }]
    can :manage, Table, user: { id: user.id }
    can :manage, WineStyle, user: { id: user.id }
    can :manage, Wine, user: { id: user.id }
    can :manage, Theme, user: { id: user.id }
  end
end
