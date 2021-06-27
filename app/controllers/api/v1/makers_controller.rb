# frozen_string_literal: true

module Api
  module V1
    class MakersController < ApplicationController
      load_and_authorize_resource

      def index
        @makers = paginate @makers.order(name: :asc)
      end

      def show; end

      def search
        @makers = Maker.search params[:q]
        @makers = paginate @makers.order(name: :asc)
      end

      def create
        @maker = Maker.new(create_params)

        if @maker.save
          render status: :created
        else
          render json: @maker.errors, status: :unprocessable_entity
        end
      end

      def update
        render json: @maker.errors, status: :unprocessable_entity unless @maker.update(update_params)
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
