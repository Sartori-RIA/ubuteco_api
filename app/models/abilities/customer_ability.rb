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
      can %i[read search], Table
      can %i[read search], Wine

      can %i[read search], Order, user_id: user.id
      can %i[read search], OrderItem, order: { user_id: user.id }
      can %i[manage search], Order, user_id: user.id, status: :open
      can %i[manage search], OrderItem, order: { user_id: user.id, status: :open }
      cannot %i[create update destroy], Order, status: :open, user_id: user.id
      cannot %i[create update destroy], OrderItem, order: { status: :open, user_id: user.id }
    end
  end
end
