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
      @user = User.new(users_params)

      if @user.save
        render json: @user, status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def update
      if @user.update(users_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
    end

    private

    def users_params
      params.permit(:name)
    end
  end
end
