class ResetPasswordsController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(reset_params)
      render json: current_user, include: [:theme]
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  protected

  def reset_params
    params.permit(:password)
  end
end
