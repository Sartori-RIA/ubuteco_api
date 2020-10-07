class Api::DrinksController < ApplicationController
  before_action :set_drink, only: [:show, :update, :destroy]
  before_action :authenticate_user!

  def index
    @drinks = Drink.where(user: current_user).order(name: :asc)

    render json: @drinks, include: %i(maker)
  end

  def show
    render json: @drink, include: %i(maker)
  end

  def create
    @drink = Drink.new(drink_params)

    if @drink.save
      render json: @drink, status: :created
    else
      render json: @drink.errors, status: :unprocessable_entity
    end
  end

  def update
    if @drink.update(drink_params)
      render json: @drink
    else
      render json: @drink.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @drink.destroy
  end

  private

  def set_drink
    @drink = Drink.find_by(id: params[:id], user: current_user)
  end

  def drink_params
    params.permit(:name,
                  :description,
                  :image,
                  :maker_id,
                  :maker,
                  :price,
                  :quantity_stock,
                  :flavor
    ).merge(user: current_user)
  end
end
