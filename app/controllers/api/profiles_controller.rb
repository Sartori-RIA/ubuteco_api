# frozen_string_literal: true

module Api
  class ProfilesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user, only: %i[me update]

    def me
      render json: @user, include: [:theme]
    end

    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    protected

    def set_user
      @user = User.find_by(id: current_user.id)
    end

    def user_params
      params.permit(
        :name,
        :company_name,
        :cnpj
      )
    end
  end
end
