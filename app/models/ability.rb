# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  def initialize(user)
    return unless user.present?
    can :manage, BeerStyle
    can :manage, Beer, user_id: user.id
    can :manage, Dish, user_id: user.id
    can :manage, DishIngredient, dish: {user_id: user.id}
    can :manage, Drink, user_id: user.id
    can :manage, Food, user_id: user.id
    can :manage, Maker, user_id: user.id
    can :manage, Order,
        user_id: user.id,
        created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    can :manage, OrderItem, order: {user_id: user.id}
    can :manage, Table, user_id: user.id
    can :manage, WineStyle, user_id: user.id
    can :manage, Wine, user_id: user.id
    can :manage, Theme, user_id: user.id
  end
end
