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
          render_model_errors(@organization)
        end
      end

      def destroy
        if @organization.destroy
          head :no_content
        else
          render_model_errors(@organization)
        end
      rescue ActiveRecord::InvalidForeignKey, ActiveRecord::DeleteRestrictionError => e
        render_api_errors([{ code: "delete_restriction", message: e.message }])
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
