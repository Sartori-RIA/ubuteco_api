# frozen_string_literal: true

module Api
  module V1
    class MakersController < ApplicationController
      load_and_authorize_resource except: :index

      def index
        authorize! :read, Maker
        @pagy, @records = pagy_search_authorized(Maker)
      end

      def show; end

      def create
        @maker = Maker.new(create_params)

        if @maker.save
          render :show, status: :created
        else
          render_model_errors(@maker)
        end
      end

      def update
        if @maker.update(update_params)
          render :show, status: :ok
        else
          render_model_errors(@maker)
        end
      end

      def destroy
        if @maker.destroy
          head :no_content
        else
          render_model_errors(@maker)
        end
      end

      protected

      def create_params
        update_params.merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :country, :logo)
      end
    end
  end
end
