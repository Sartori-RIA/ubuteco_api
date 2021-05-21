# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    load_and_authorize_resource

    def show; end

    def create
      @user = User.new(create_params)
      if @user.save
        render status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def update
      if @user.update(update_params)
        render status: :ok
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
    end

    def search
      @users = User.search params[:q]
      @users = paginate @users.order(name: :asc), include: %i[role organization]
    end

    def email_available?
      user = User.find_by(email: params[:q])
      if user.nil?
        render json: {}, status: :no_content
      else
        render json: {}, status: :ok
      end
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
      ).merge(organization_id: current_user.organization_id)
    end

    def update_params
      params.permit(
        :name,
        :email,
        :password,
        :avatar,
        :role,
      )
    end
  end
end
