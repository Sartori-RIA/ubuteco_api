# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ApiErrorRenderable
  include CanCan::ControllerAdditions
  include Devise::Controllers::Helpers
  include Pagy::Method
  include SearchkickAuthorizable
  include SetCurrentTenant
  include SetOrganizationRegional

  prepend_before_action :authenticate_user!

  def append_info_to_payload(payload)
    super
    payload[:user_id] = current_user&.id
    payload[:organization_id] = Current.organization_id if defined?(Current)
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug { "Access denied on #{exception.action} #{exception.subject.inspect}" }
    head :forbidden
  end

  private

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  def current_ability
    controller_name_segments = params[:controller].split('/')
    controller_name = controller_name_segments.join('/').camelize
    @current_ability ||= load_permissions(params:, controller_name:)
  end

  def load_permissions(params:, controller_name:)
    return Abilities::BaseAbility.new if current_user.blank?

    case current_user.role.name
    when 'SUPER_ADMIN'
      Abilities::SuperAdminAbility.new user: current_user, params:, controller_name:
    when 'ADMIN'
      Abilities::AdminAbility.new user: current_user, params:, controller_name:
    when 'KITCHEN'
      Abilities::KitchenAbility.new user: current_user, controller_name:
    when 'WAITER'
      Abilities::WaiterAbility.new user: current_user, params:, controller_name:
    when 'CASH_REGISTER'
      Abilities::CashRegisterAbility.new user: current_user, params:, controller_name:
    when 'CUSTOMER'
      Abilities::CustomerAbility.new user: current_user, params:, controller_name:
    else
      Abilities::BaseAbility.new
    end
  end
end
