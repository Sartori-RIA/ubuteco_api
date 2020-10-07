class Api::Profiles::ThemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_theme, only: [:show, :update, :destroy]

  def show
    render json: @theme
  end

  def update
    if @theme.update(theme_params)
      render json: @theme
    else
      render json: @theme.errors, status: :unprocessable_entity
    end
  end

  private

  def set_theme
    @theme = Theme.find_by(id: params[:id],user: current_user)
  end

  def theme_params
    puts params
    params.permit(:id,
                  :color_header,
                  :color_sidebar,
                  :color_footer,
                  :rtl)
        .merge(user: current_user)
  end
end
