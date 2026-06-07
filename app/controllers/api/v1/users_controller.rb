# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_user!, only: :email_available?
      skip_load_resource only: :email_available?
      skip_authorize_resource only: :email_available?
      load_and_authorize_resource except: %i[index email_available?]

      before_action :authorize_assignable_role!, only: %i[create update]

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

      def authorize_assignable_role!
        role_id = params[:role_id]
        return if role_id.blank?

        role = Role.find_by(id: role_id)
        return if role.blank?
        return unless role.name == 'SUPER_ADMIN'

        render_i18n_api_error(:role_assignment_forbidden, status: :forbidden)
      end
    end
  end
end
