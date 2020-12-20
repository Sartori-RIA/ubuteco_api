# frozen_string_literal: true

module Abilities
  class CustomerAbility < Abilities::BaseAbility
    def initialize(user:)
      super()
      can :manage, User, id: user.id
      can %i[search], Beer
      can %i[read search], Dish
      can %i[read search], Drink
      can %i[read search], Food
      can %i[read search], Maker
      can %i[manage search], Order, user_id: user.id
      can %i[manage search], OrderItem, order: { user_id: user.id }
      can %i[read search], Table
      can %i[read search], Wine
      cannot %i[create update destroy], Order, status: :payed
      cannot %i[create update destroy], OrderItem, order: { status: :payed }
    end
  end
end
