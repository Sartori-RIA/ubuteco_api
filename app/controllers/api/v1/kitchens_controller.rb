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

        @kitchen = ::Kitchen::UpdateItemStatus.call(
          order_item: @kitchen,
          status: update_params[:status],
          organization:
        )

        if @kitchen.errors.any?
          render_model_errors(@kitchen)
        else
          render :show, status: :ok
        end
      rescue Kitchen::UpdateItemStatus::KitchenClosed
        render_i18n_api_error(:kitchen_closed, status: :forbidden)
      end

      protected

      def update_params
        params.permit(:status)
      end
    end
  end
end
