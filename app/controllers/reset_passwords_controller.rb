# frozen_string_literal: true

class ResetPasswordsController < ApplicationController
  authorize_resource class: User
  respond_to :json

  def update
    if current_user.update(reset_params)
      @user = current_user
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  protected

  def reset_params
    params.require(:reset_params).permit(:password)
  end
end
