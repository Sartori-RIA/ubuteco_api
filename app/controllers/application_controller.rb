# frozen_string_literal: true

class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied do |_exception|
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

  def current_ability
    controller_name_segments = params[:controller].split('/')
    controller_name = controller_name_segments.join('/').camelize
    @current_ability ||= Ability.new(current_user, params, controller_name)
  end
end
