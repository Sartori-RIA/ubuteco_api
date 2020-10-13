# frozen_string_literal: true

# noinspection ALL
class Ability
  include CanCan::Ability

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  def initialize(user)
    return if user.blank?

    if user.role.name == 'ADMIN'
      only_admin(user)
    else
      only_authenticated_user(user)
    end
  end

  private

  def only_admin(_user)
    can :manage, BeerStyle
    can :manage, WineStyle
    can :manage, User
  end

  def only_authenticated_user(user)
    can :read, BeerStyle
    can :read, WineStyle
    can :manage, User, id: user.id
    can %i[manage search], Beer, user_id: user.id
    can %i[manage search], Dish, user_id: user.id
    can :manage, DishIngredient, dish: {user_id: user.id}
    can %i[manage search], Drink, user_id: user.id
    can %i[manage search], Food, user_id: user.id
    can %i[manage search], Maker, user_id: user.id
    can %i[manage search], Order, user_id: user.id
    cannot :update, Order, user_id: user.id, status: 'payed'
    can :manage, OrderItem, order: {user_id: user.id}
    can %i[manage search], Table, user_id: user.id
    can %i[manage search], Wine, user_id: user.id
    can :manage, Theme, user_id: user.id
  end
end
