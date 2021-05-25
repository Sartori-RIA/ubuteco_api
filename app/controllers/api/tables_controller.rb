# frozen_string_literal: true

module Api
  class TablesController < ApplicationController
    load_and_authorize_resource

    def index
      @tables = paginate @tables.order(name: :asc)
    end

    def show; end

    def search
      @tables = Table.search params[:q]
      @tables = paginate @tables.order(name: :asc)
    end

    def create
      @table = Table.new(create_params)

      if @table.save
        render status: :created
      else
        render json: @table.errors, status: :unprocessable_entity
      end
    end

    def update
      unless @table.update(update_params)
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
