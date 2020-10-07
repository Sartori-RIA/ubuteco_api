class Api::BeerStylesController < ApplicationController
  before_action :set_beer_style, only: [:show, :update, :destroy]
  before_action :authenticate_user!

  def index
    @beer_styles = BeerStyle.where(user: current_user).order(name: :asc)

    render json: @beer_styles
  end

  def show
    render json: @beer_style
  end

  def create
    @beer_style = BeerStyle.new(beer_style_params)

    if @beer_style.save
      render json: @beer_style, status: :created
    else
      render json: @beer_style.errors, status: :unprocessable_entity
    end
  end

  def update
    if @beer_style.update(beer_style_params)
      render json: @beer_style
    else
      render json: @beer_style.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @beer_style.destroy
  end

  private

  def set_beer_style
    @beer_style = BeerStyle.find_by(id: params[:id], user: current_user)
  end

  def beer_style_params
    params.permit(:name).merge(user: current_user)
  end
end
