# frozen_string_literal: true

module Api
  module V1
    class TablesController < ApplicationController
      load_and_authorize_resource

      def index; end

      def show; end

      def create
        @table = Table.new(create_params)

        if @table.save
          render :show, status: :created
        else
          render_model_errors(@table)
        end
      end

      def update
        if @table.update(update_params)
          render :show, status: :ok
        else
          render_model_errors(@table)
        end
      end

      def destroy
        if @table.destroy
          head :no_content
        else
          render_model_errors(@table)
        end
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
