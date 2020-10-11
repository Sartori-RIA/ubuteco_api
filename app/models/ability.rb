# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  def initialize(user)
    return unless user.present?
    can :manage, BeerStyle
    can [:manage, :search], Beer, user_id: user.id
    can [:manage, :search], Dish, user_id: user.id
    can :manage, DishIngredient, dish: {user_id: user.id}
    can [:manage, :search], Drink, user_id: user.id
    can [:manage, :search], Food, user_id: user.id
    can [:manage, :search], Maker, user_id: user.id
    can [:manage, :search], Order,
        user_id: user.id,
        created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    can :manage, OrderItem, order: {user_id: user.id}
    can [:manage, :search], Table, user_id: user.id
    can :manage, WineStyle, user_id: user.id
    can [:manage, :search], Wine, user_id: user.id
    can :manage, Theme, user_id: user.id
  end
end
