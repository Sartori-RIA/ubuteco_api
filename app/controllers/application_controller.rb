# frozen_string_literal: true

class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    render json: {}, status: :forbidden
  end

  def render_resource(resource)
    if resource.errors.empty?
      render json: resource
    else
      validation_error(resource)
    end
  end

  def validation_error(resource)
    render json: {
      errors: [
        {
          status: '400',
          title: 'Bad Request',
          detail: resource.errors,
          code: '100'
        }
      ]
    }, status: :bad_request
  end

  private

  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  def current_ability
    controller_name_segments = params[:controller].split('/')
    controller_name = controller_name_segments.join('/').camelize
    @current_ability ||= load_permissions(params: params, controller_name: controller_name)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
  # :reek:TooManyStatements:
  def load_permissions(params:, controller_name:)
    return Abilities::BaseAbility.new if current_user.blank?

    case current_user.role.name
    when 'SUPER_ADMIN'
      Abilities::SuperAdminAbility.new user: current_user, params: params, controller_name: controller_name
    when 'ADMIN'
      Abilities::AdminAbility.new user: current_user, params: params, controller_name: controller_name
    when 'KITCHEN'
      Abilities::KitchenAbility.new user: current_user, controller_name: controller_name
    when 'WAITER'
      Abilities::WaiterAbility.new user: current_user, params: params, controller_name: controller_name
    when 'CASH_REGISTER'
      Abilities::CashRegisterAbility.new user: current_user, params: params, controller_name: controller_name
    when 'CUSTOMER'
      Abilities::CustomerAbility.new user: current_user, params: params, controller_name: controller_name
    else
      Abilities::BaseAbility.new
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
end
