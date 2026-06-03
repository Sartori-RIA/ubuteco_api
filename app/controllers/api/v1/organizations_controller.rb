# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApplicationController
      load_and_authorize_resource except: :index

      def index
        authorize! :read, Organization
        @pagy, @records = pagy_search_authorized(Organization)
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
        if @organization.destroy
          head :no_content
        else
          render json: @organization.errors.full_messages, status: :unprocessable_content
        end
      rescue ActiveRecord::InvalidForeignKey, ActiveRecord::DeleteRestrictionError => e
        render json: [e.message], status: :unprocessable_content
      end

      def phone_available?
        Organization.exists?(phone: params[:q]) ? head(:ok) : head(:no_content)
      end

      protected

      def update_params
        if can?(:manage, @organization)
          params.permit(
            :name, :phone, :user_id, :logo, :operational_status,
            :locale, :default_currency, :timezone
          )
        else
          params.permit(:operational_status)
        end
      end
    end
  end
end
