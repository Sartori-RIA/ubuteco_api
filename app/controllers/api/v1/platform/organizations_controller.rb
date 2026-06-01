# frozen_string_literal: true

module Api
  module V1
    module Platform
      class OrganizationsController < BaseController
        load_and_authorize_resource class: Organization

        def index
          authorize! :read, Organization
          @pagy, @records = pagy_search_authorized(Organization)
          render 'api/v1/organizations/index'
        end

        def show
          render 'api/v1/organizations/show'
        end

        def update
          if @organization.update(update_params)
            render 'api/v1/organizations/show'
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
        end

        protected

        def update_params
          params.permit(
            :name, :phone, :user_id, :logo, :operational_status,
            :locale, :default_currency, :timezone
          )
        end
      end
    end
  end
end
