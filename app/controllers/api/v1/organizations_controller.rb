# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApplicationController
      load_and_authorize_resource

      def index
        @organization = Organization.search params[:q] if params[:q].present?
        pagy_render @organizations.order(name: :asc)
      end

      def show; end

      def update
        render json: @organization.errors, status: :unprocessable_entity unless @organization.update(update_params)
      end

      def destroy
        @organization.user.destroy
        @organization.destroy
      end

      def phone_available?
        organization = Organization.find_by(phone: params[:q])
        if organization.blank?
          render json: {}, status: :no_content
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
