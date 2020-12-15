# frozen_string_literal: true

# noinspection ALL
class Ability
  include CanCan::Ability

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  def initialize(user, params, controller_name)
    Ability::PublicAbility.new(user, params, controller_name)

    return if user.blank?

    case user.role.name
    when 'STAFF'
      StaffAbility.new(user, params, controller_name)
    when 'ADMIN'
      Abilities::AdminAbility.new(user, params, controller_name)
    when 'KITCHEN'
      Abilities::KitchenAbility.new(user, params, controller_name)
    when 'WAITER'
      Abilities::WaiterAbility.new(user, params, controller_name)
    when 'CASH_REGISTER'
      Abilities::KitchenAbility.new(user, params, controller_name)
    when 'CUSTOMER'
      Abilities::CustomerAbility.new(user, params, controller_name)
    end
  end
end
