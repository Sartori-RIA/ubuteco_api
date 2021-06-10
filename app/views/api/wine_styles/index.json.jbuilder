# frozen_string_literal: true

json.array! @wine_styles, partial: 'api/wine_styles/wine_style', as: :wine_style
