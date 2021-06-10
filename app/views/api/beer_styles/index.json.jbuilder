# frozen_string_literal: true

json.array! @beer_styles, partial: 'api/beer_styles/beer_style', as: :beer_style
