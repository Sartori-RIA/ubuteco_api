# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @users.order(name: :asc)
    end

    def show
      render json: @user
    end

    def create
      @user = User.new(create_params)
      if @user.save
        render json: @user, status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def update
      if @user.update(update_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
    end

    private

    def create_params
      params.permit(
        :name,
        :email,
        :password,
        :avatar,
        :role,
        :role_id,
        :organization_id
      )
    end

    def update_params
      params.permit(
        :name,
        :email,
        :password,
        :avatar,
        :role,
        :role_id
      )
    end
  end
end
