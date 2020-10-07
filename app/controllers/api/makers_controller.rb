class Api::MakersController < ApplicationController
  before_action :set_maker, only: [:show, :update, :destroy]
  before_action :authenticate_user!

  def index
    @makers = Maker.where(user: current_user).order(name: :asc)

    render json: @makers
  end

  def show
    render json: @maker
  end

  def create
    @maker = Maker.new(maker_params)

    if @maker.save
      render json: @maker, status: :created
    else
      render json: @maker.errors, status: :unprocessable_entity
    end
  end

  def update
    if @maker.update(maker_params)
      render json: @maker
    else
      render json: @maker.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @maker.destroy
  end

  private

  def set_maker
    @maker = Maker.find_by(id: params[:id], user: current_user)
  end

  def maker_params
    params.permit(:name, :country).merge(user: current_user)
  end
end
