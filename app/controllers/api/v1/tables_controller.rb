# frozen_string_literal: true

module Api
  class V1::TablesController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @tables.order(name: :asc)
    end

    def show
      render json: @table
    end

    def search
      @tables = Table.search params[:q]
      paginate json: @tables.order(name: :asc)
    end

    def create
      @table = Table.new(create_params)

      if @table.save
        render json: @table, status: :created
      else
        render json: @table.errors, status: :unprocessable_entity
      end
    end

    def update
      if @table.update(update_params)
        render json: @table
      else
        render json: @table.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @table.destroy
    end

    private

    def create_params
      update_params.merge(organization_id: current_user.organization_id)
    end

    def update_params
      params.permit(:name, :chairs)
    end
  end
end
