# frozen_string_literal: true

module Api
  class TablesController < ApplicationController
    load_and_authorize_resource

    def index
      paginate json: @tables.order(name: :asc)
    end

    def show
      render json: @table
    end

    def create
      @table = Table.new(table_params)

      if @table.save
        render json: @table, status: :created
      else
        render json: @table.errors, status: :unprocessable_entity
      end
    end

    def update
      if @table.update(table_params)
        render json: @table
      else
        render json: @table.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @table.destroy
    end

    private

    def table_params
      params.permit(:name, :chairs).merge(user: current_user)
    end
  end
end
