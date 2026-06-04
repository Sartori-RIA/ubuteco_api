# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_user!, only: :email_available?
      skip_load_resource only: :email_available?
      skip_authorize_resource only: :email_available?
      load_and_authorize_resource except: %i[index email_available?]

      def index
        authorize! :read, User
        @pagy, @records = pagy_search_authorized(User)
      end

      def show; end

      def create
        @user = User.new(create_params)
        if @user.save
          render :show, status: :created
        else
          render_model_errors(@user)
        end
      end

      def update
        if @user.update(update_params)
          render :show
        else
          render_model_errors(@user)
        end
      end

      def destroy
        if @user.destroy
          head :no_content
        else
          render_model_errors(@user)
        end
      end

      def email_available?
        User.exists?(email: params[:q]) ? head(:ok) : head(:no_content)
      end

      protected

      def create_params
        params.permit(
          :name, :email, :password, :avatar, :role_id
        ).merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :email, :password, :avatar, :role_id)
      end
    end
  end
end
