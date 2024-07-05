# frozen_string_literal: true

module Api
  module V1
    class TablesController < ApplicationController
      load_and_authorize_resource

      def index
        @tables = Table.search params[:q] if params[:q].present?
        render json: @tables.order(name: :asc), status: :ok
      end

      def show; end

      def create
        @table = Table.new(create_params)

        if @table.save
          render status: :created
        else
          render json: @table.errors, status: :unprocessable_entity
        end
      end

      def update
        render json: @table.errors, status: :unprocessable_entity unless @table.update(update_params)
      end

      def destroy
        @table.destroy
      end

      protected

      def create_params
        update_params.merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :chairs)
      end
    end
  end
end
