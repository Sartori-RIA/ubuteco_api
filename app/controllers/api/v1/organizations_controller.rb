# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApplicationController
      load_and_authorize_resource

      def index
        search = Organization.pagy_search(params[:q].presence || "*", page: params[:page], per_page: 20)
        @pagy, @records = pagy(:searchkick, search)
      end

      def show; end

      def update
        if @organization.update(update_params)
          render :show
        else
          render json: @organization.errors.full_messages, status: :unprocessable_content
        end
      end

      def destroy
        @organization.user.destroy
        @organization.destroy
      end

      def phone_available?
        Organization.exists?(phone: params[:q]) ? head(:ok) : head(:no_content)
      end

      protected

      def update_params
        params.permit(:name, :phone, :user_id, :logo)
      end
    end
  end
end
