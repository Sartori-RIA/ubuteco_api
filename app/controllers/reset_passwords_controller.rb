# frozen_string_literal: true

class ResetPasswordsController < ApplicationController
  authorize_resource class: User

  def update
    if current_user.update(reset_params)
      render json: current_user, include: [:role, { organization: { include: [:theme] } }]
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  protected

  def reset_params
    params.require(:reset_params).permit(:password)
  end
end
