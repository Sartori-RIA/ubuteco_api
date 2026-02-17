# frozen_string_literal: true

module Api
  module V1
    class MakersController < ApplicationController
      load_and_authorize_resource

      def index
        search = Maker.pagy_search(params[:q].presence || "*", page: params[:page], per_page: 20)
        @pagy, @records = pagy(:searchkick, search)
      end

      def show; end

      def create
        @maker = Maker.new(create_params)

        if @maker.save
          render :show, status: :created
        else
          render json: @maker.errors.full_messages, status: :unprocessable_content
        end
      end

      def update
        if @maker.update(update_params)
          render :show, status: :ok
        else
          render json: @maker.errors.full_messages, status: :unprocessable_content
        end
      end

      def destroy
        @maker.destroy
      end

      protected

      def create_params
        update_params.merge(organization_id: current_user.organization_id)
      end

      def update_params
        params.permit(:name, :country)
      end
    end
  end
end
