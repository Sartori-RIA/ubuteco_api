# frozen_string_literal: true

module Api
  module V1
    class TablesController < ApplicationController
      load_and_authorize_resource

      def index
        search = Table.pagy_search(params[:q].presence || "*", page: params[:page], per_page: 20)
        @pagy, @records = pagy(:searchkick, search)
      end

      def show; end

      def create
        @table = Table.new(create_params)

        if @table.save
          render :show, status: :created
        else
          render json: @table.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @table.update(update_params)
          render :show, status: :ok
        else
          render json: @table.errors.full_messages, status: :unprocessable_content
        end
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
