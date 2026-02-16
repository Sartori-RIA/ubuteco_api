# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApplicationController
      load_and_authorize_resource

      def index
        @organization = Organization.pagy_search params[:q] if params[:q].present?
        pagy_render @organizations.order(name: :asc)
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
        organization = Organization.find_by(phone: params[:q])
        if organization.blank?
          head :no_content
        else
          render json: {}, status: :ok
        end
      end

      protected

      def update_params
        params.permit(:name, :phone, :user_id, :logo)
      end
    end
  end
end
