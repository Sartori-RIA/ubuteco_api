# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      load_and_authorize_resource

      def index
        search = User.pagy_search(params[:q].presence || "*", page: params[:page], per_page: 20)
        @pagy, @records = pagy(:searchkick, search)
      end

      def show; end

      def create
        @user = User.new(create_params)
        if @user.save
          render :show, status: :created
        else
          render json: @user.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @user.update(update_params)
          render :show
        else
          render json: @user.errors.full_messages, status: :unprocessable_content
        end
      end

      def destroy
        @user.destroy
      end

      def email_available?
        User.exists?(email: params[:q]) ? head(:ok) : head(:no_content)
      end

      protected

      def create_params
        params.permit(
          :name, :email, :password, :avatar, :role_id, :organization_id
        ).merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :email, :password, :avatar, :role_id)
      end
    end
  end
end
