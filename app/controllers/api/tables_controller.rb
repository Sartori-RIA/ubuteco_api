class Api::TablesController < ApplicationController
  before_action :set_table, only: [:show, :update, :destroy]
  before_action :authenticate_user!

  def index
    @tables = Table.where(user: current_user).order(name: :asc)

    render json: @tables
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

  def set_table
    @table = Table.find_by(id: params[:id], user: current_user)
  end

  def table_params
    params.permit(:name, :chairs).merge(user: current_user)
  end
end
