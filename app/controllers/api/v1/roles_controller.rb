# frozen_string_literal: true

module Api
  module V1
    class RolesController < ApplicationController
      load_and_authorize_resource

      def index; end

      def show; end

      def create
        @role = Role.new(create_params)

        if @role.save
          render :show, status: :created
        else
          render_model_errors(@role)
        end
      end

      def update
        if @role.update(update_params)
          render :show, status: :ok
        else
          render_model_errors(@role)
        end
      end

      def destroy
        if @role.destroy
          head :no_content
        else
          render_model_errors(@role)
        end
      end

      protected

      def create_params
        params.permit(:name)
      end

      def update_params
        params.permit( :name)
      end
    end
  end
end
