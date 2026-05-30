# frozen_string_literal: true

module Api
  module V1
    class KitchensController < ApplicationController
      load_and_authorize_resource class: OrderItem, except: :index

      def index
        authorize! :read, OrderItem

        organization = Current.organization
        unless organization
          return head :forbidden
        end

        if organization.closed?
          @kitchens = OrderItem.none
          return render :index
        end

        scope = OrderItem.kitchen_queue_for(organization.id)
        scope = scope.kitchen_active if params[:active].present?

        @kitchens = scope.includes(:item, order: :table).order(:created_at)
      end

      def show; end

      def update
        organization = Current.organization
        unless organization
          return head :forbidden
        end

        if organization.closed?
          return render json: ['Kitchen is closed'], status: :forbidden
        end

        if @kitchen.update(update_params)
          render :show, status: :ok
        else
          render json: @kitchen.errors.full_messages, status: :unprocessable_content
        end
      end

      protected

      def update_params
        params.permit(:status)
      end
    end
  end
end
