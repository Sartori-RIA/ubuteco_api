# frozen_string_literal: true

class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    render status: :forbidden
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
    @current_ability ||= case current_user.role.name
                         when 'SUPER_ADMIN'
                           Abilities::SuperAdminAbility.new user: current_user
                         when 'ADMIN'
                           Abilities::AdminAbility.new user: current_user,
                                                       params: params
                         when 'KITCHEN'
                           Abilities::KitchenAbility.new user: current_user,
                                                         controller_name: controller_name
                         when 'WAITER'
                           Abilities::WaiterAbility.new user: current_user
                         when 'CASH_REGISTER'
                           Abilities::CashRegisterAbility.new user: current_user,
                                                              params: params,
                                                              controller_name: controller_name
                         when 'CUSTOMER'
                           Abilities::CustomerAbility.new user: current_user,
                                                          params: params
                         else
                           Abilities::BaseAbility.new
                         end
  end
end
