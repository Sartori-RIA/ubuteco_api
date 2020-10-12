# frozen_string_literal: true

#noinspection ALL
class Ability
  include CanCan::Ability

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  def initialize(user)
    return if user.blank?

    only_authenticated_user(user)
  end

  private

  def only_authenticated_user(user)
    can :manage, User, id: user.id
    can :manage, BeerStyle, user_id: user.id
    can %i[manage search], Beer, user_id: user.id
    can %i[manage search], Dish, user_id: user.id
    can :manage, DishIngredient, dish: { user_id: user.id }
    can %i[manage search], Drink, user_id: user.id
    can %i[manage search], Food, user_id: user.id
    can %i[manage search], Maker, user_id: user.id
    can %i[manage search], Order, user_id: user.id
    can :manage, OrderItem, order: { user_id: user.id }
    can %i[manage search], Table, user_id: user.id
    can :manage, WineStyle, user_id: user.id
    can %i[manage search], Wine, user_id: user.id
    can :manage, Theme, user_id: user.id
  end
end
